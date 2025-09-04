import Foundation
import SQLite

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let queue = DispatchQueue(label: "db.queue")
    private let db: Connection

    // MARK: - ISO8601 helpers
    static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func isoString(_ date: Date) -> String { Self.isoFormatter.string(from: date) }
    func date(from iso: String) -> Date? { Self.isoFormatter.date(from: iso) }

    private init() {
        // Open/create database synchronously during initialization
        let dbURL = DatabaseManager.databaseURL()
        do {
            self.db = try Connection(dbURL.path)
            try? (dbURL as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try self.runMigrations()
        } catch {
            fatalError("Failed to open database: \(error)")
        }
    }

    private static func databaseURL() -> URL {
        let fm = FileManager.default
        let base = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("Incubate", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("db.sqlite", isDirectory: false)
    }

    private func runMigrations() throws {
        let createSQL = """
        CREATE TABLE IF NOT EXISTS entries (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('raw','todos','goals','reflection')),
          title TEXT,
          text TEXT NOT NULL,
          tags TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          deleted_at TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_entries_user    ON entries(user_id);
        CREATE INDEX IF NOT EXISTS idx_entries_type    ON entries(type);
        CREATE INDEX IF NOT EXISTS idx_entries_created ON entries(type, created_at DESC);
        
        CREATE TABLE IF NOT EXISTS todo_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entry_id TEXT NOT NULL,
          position INTEGER NOT NULL,
          text TEXT NOT NULL,
          is_done INTEGER NOT NULL DEFAULT 0
        );
        CREATE INDEX IF NOT EXISTS idx_todo_entry_pos ON todo_items(entry_id, position);
        
        CREATE TABLE IF NOT EXISTS goal_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entry_id TEXT NOT NULL,
          position INTEGER NOT NULL,
          bullet TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_goal_entry_pos ON goal_items(entry_id, position);
        
        CREATE TABLE IF NOT EXISTS reflection_qas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entry_id TEXT NOT NULL,
          position INTEGER NOT NULL,
          question TEXT NOT NULL,
          answer TEXT NOT NULL
        );
        CREATE INDEX IF NOT EXISTS idx_reflection_entry_pos ON reflection_qas(entry_id, position);
        """
        try db.execute(createSQL)
    }

    // MARK: - Public API
    func insertDummyEntry() throws -> Entry {
        let entry = Entry(
            id: UUID().uuidString,
            userId: "local-user",
            type: .raw,
            title: nil,
            text: "Hello SQLite",
            tags: ["demo"],
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
        try insert(entry)
        return entry
    }

    func fetchAllActive(limit: Int = 1000) throws -> [Entry] {
        try queue.sync {
            var results: [Entry] = []
            let sql = "SELECT id, user_id, type, title, text, tags, created_at, updated_at, deleted_at FROM entries WHERE deleted_at IS NULL ORDER BY datetime(created_at) DESC LIMIT ?;"
            let stmt = try db.prepare(sql, limit)
            for row in stmt {
                let id = row[0] as? String ?? UUID().uuidString
                let userId = row[1] as? String ?? "local-user"
                let typeRaw = row[2] as? String ?? EntryType.raw.rawValue
                let title = row[3] as? String
                let text = row[4] as? String ?? ""
                let tagsJSON = row[5] as? String
                let createdAtISO = row[6] as? String ?? isoString(Date())
                let updatedAtISO = row[7] as? String ?? createdAtISO
                let deletedAtISO = row[8] as? String

                let type = EntryType(rawValue: typeRaw) ?? .raw
                let createdAt = date(from: createdAtISO) ?? Date()
                let updatedAt = date(from: updatedAtISO) ?? createdAt
                let deletedAt = deletedAtISO.flatMap { date(from: $0) }

                let tags: [String]
                if let tagsJSON = tagsJSON, let data = tagsJSON.data(using: .utf8) {
                    tags = (try? JSONDecoder().decode([String].self, from: data)) ?? []
                } else {
                    tags = []
                }

                results.append(Entry(id: id, userId: userId, type: type, title: title, text: text, tags: tags, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt))
            }
            return results
        }
    }

    // MARK: - CRUD Operations
    func saveNewRaw(title: String?, body: String) throws -> Entry {
        try queue.sync {
            let entry = Entry(
                id: UUID().uuidString,
                userId: "local-user",
                type: .raw,
                title: title,
                text: body,
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                deletedAt: nil
            )
            try insert(entry)
            return entry
        }
    }

    func saveNewTodos(title: String, items: [(text: String, isDone: Bool)]) throws -> Entry {
        try queue.sync {
            let entry = Entry(
                id: UUID().uuidString,
                userId: "local-user",
                type: .todos,
                title: title,
                text: "",
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                deletedAt: nil
            )

            try db.transaction {
                try insert(entry)
                for (index, item) in items.enumerated() {
                    let sql = "INSERT INTO todo_items (entry_id, position, text, is_done) VALUES (?, ?, ?, ?);"
                    try db.run(sql, entry.id, index, item.text, item.isDone ? 1 : 0)
                }
            }

            return entry
        }
    }

    func saveNewGoals(title: String, bullets: [String]) throws -> Entry {
        try queue.sync {
            let entry = Entry(
                id: UUID().uuidString,
                userId: "local-user",
                type: .goals,
                title: title,
                text: "",
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                deletedAt: nil
            )

            try db.transaction {
                try insert(entry)
                for (index, bullet) in bullets.enumerated() {
                    let sql = "INSERT INTO goal_items (entry_id, position, bullet) VALUES (?, ?, ?);"
                    try db.run(sql, entry.id, index, bullet)
                }
            }

            return entry
        }
    }

    func fetchByType(type: EntryType, limit: Int = 1000) throws -> [Entry] {
        try queue.sync {
            var results: [Entry] = []
            let sql = "SELECT id, user_id, type, title, text, tags, created_at, updated_at, deleted_at FROM entries WHERE type = ? AND deleted_at IS NULL ORDER BY datetime(created_at) DESC LIMIT ?;"
            let stmt = try db.prepare(sql, type.rawValue, limit)
            for row in stmt {
                let id = row[0] as? String ?? UUID().uuidString
                let userId = row[1] as? String ?? "local-user"
                let typeRaw = row[2] as? String ?? EntryType.raw.rawValue
                let title = row[3] as? String
                let text = row[4] as? String ?? ""
                let tagsJSON = row[5] as? String
                let createdAtISO = row[6] as? String ?? isoString(Date())
                let updatedAtISO = row[7] as? String ?? createdAtISO
                let deletedAtISO = row[8] as? String

                let type = EntryType(rawValue: typeRaw) ?? .raw
                let createdAt = date(from: createdAtISO) ?? Date()
                let updatedAt = date(from: updatedAtISO) ?? createdAt
                let deletedAt = deletedAtISO.flatMap { date(from: $0) }

                let tags: [String]
                if let tagsJSON = tagsJSON, let data = tagsJSON.data(using: .utf8) {
                    tags = (try? JSONDecoder().decode([String].self, from: data)) ?? []
                } else {
                    tags = []
                }

                results.append(Entry(id: id, userId: userId, type: type, title: title, text: text, tags: tags, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt))
            }
            return results
        }
    }

    func fetchEntryDetail(id: String) throws -> EntryDetail? {
        try queue.sync {
            // Fetch entry
            let entrySQL = "SELECT id, user_id, type, title, text, tags, created_at, updated_at, deleted_at FROM entries WHERE id = ? AND deleted_at IS NULL;"
            let entryStmt = try db.prepare(entrySQL, id)
            
            guard let row = entryStmt.makeIterator().next() else { return nil }
            
            let entryId = row[0] as? String ?? ""
            let userId = row[1] as? String ?? "local-user"
            let typeRaw = row[2] as? String ?? EntryType.raw.rawValue
            let title = row[3] as? String
            let text = row[4] as? String ?? ""
            let tagsJSON = row[5] as? String
            let createdAtISO = row[6] as? String ?? isoString(Date())
            let updatedAtISO = row[7] as? String ?? createdAtISO
            let deletedAtISO = row[8] as? String

            let type = EntryType(rawValue: typeRaw) ?? .raw
            let createdAt = date(from: createdAtISO) ?? Date()
            let updatedAt = date(from: updatedAtISO) ?? createdAt
            let deletedAt = deletedAtISO.flatMap { date(from: $0) }

            let tags: [String]
            if let tagsJSON = tagsJSON, let data = tagsJSON.data(using: .utf8) {
                tags = (try? JSONDecoder().decode([String].self, from: data)) ?? []
            } else {
                tags = []
            }

            let entry = Entry(id: entryId, userId: userId, type: type, title: title, text: text, tags: tags, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)

            // Fetch child items based on type
            var todoItems: [TodoItem]?
            var goalItems: [GoalItem]?
            var reflectionQAs: [ReflectionQA]?

            if type == .todos {
                let todoSQL = "SELECT id, entry_id, position, text, is_done FROM todo_items WHERE entry_id = ? ORDER BY position;"
                let todoStmt = try db.prepare(todoSQL, id)
                todoItems = []
                for todoRow in todoStmt {
                    let todoId = todoRow[0] as? Int64 ?? 0
                    let todoEntryId = todoRow[1] as? String ?? ""
                    let position = todoRow[2] as? Int ?? 0
                    let text = todoRow[3] as? String ?? ""
                    let isDone = (todoRow[4] as? Int ?? 0) == 1
                    todoItems?.append(TodoItem(id: todoId, entryId: todoEntryId, position: position, text: text, isDone: isDone))
                }
            } else if type == .goals {
                let goalSQL = "SELECT id, entry_id, position, bullet FROM goal_items WHERE entry_id = ? ORDER BY position;"
                let goalStmt = try db.prepare(goalSQL, id)
                goalItems = []
                for goalRow in goalStmt {
                    let goalId = goalRow[0] as? Int64 ?? 0
                    let goalEntryId = goalRow[1] as? String ?? ""
                    let position = goalRow[2] as? Int ?? 0
                    let bullet = goalRow[3] as? String ?? ""
                    goalItems?.append(GoalItem(id: goalId, entryId: goalEntryId, position: position, bullet: bullet))
                }
            } else if type == .reflection {
                let reflectionSQL = "SELECT id, entry_id, position, question, answer FROM reflection_qas WHERE entry_id = ? ORDER BY position;"
                let reflectionStmt = try db.prepare(reflectionSQL, id)
                reflectionQAs = []
                for reflectionRow in reflectionStmt {
                    let reflectionId = reflectionRow[0] as? Int64 ?? 0
                    let reflectionEntryId = reflectionRow[1] as? String ?? ""
                    let position = reflectionRow[2] as? Int ?? 0
                    let question = reflectionRow[3] as? String ?? ""
                    let answer = reflectionRow[4] as? String ?? ""
                    reflectionQAs?.append(ReflectionQA(id: reflectionId, entryId: reflectionEntryId, position: position, question: question, answer: answer))
                }
            }

            return EntryDetail(entry: entry, todoItems: todoItems, goalItems: goalItems, reflectionQAs: reflectionQAs)
        }
    }

    func updateEntryMeta(id: String, title: String?, text: String) throws {
        try queue.sync {
            let sql = "UPDATE entries SET title = ?, text = ?, updated_at = ? WHERE id = ?;"
            try db.run(sql, title, text, isoString(Date()), id)
        }
    }

    func updateTodoItem(id: Int64, isDone: Bool) throws {
        try queue.sync {
            let sql = "UPDATE todo_items SET is_done = ? WHERE id = ?;"
            try db.run(sql, isDone ? 1 : 0, id)
        }
    }

    func updateGoalBullet(id: Int64, bullet: String) throws {
        try queue.sync {
            let sql = "UPDATE goal_items SET bullet = ? WHERE id = ?;"
            try db.run(sql, bullet, id)
        }
    }

    func softDeleteEntry(id: String) throws {
        try queue.sync {
            let sql = "UPDATE entries SET deleted_at = ? WHERE id = ?;"
            try db.run(sql, isoString(Date()), id)
        }
    }
    
    // MARK: - Reflection Methods
    
    func saveNewReflection(title: String?, qas: [(String, String)]) throws -> Entry {
        try queue.sync {
            let entry = Entry(
                id: UUID().uuidString,
                userId: "local-user",
                type: .reflection,
                title: title,
                text: "",
                tags: [],
                createdAt: Date(),
                updatedAt: Date(),
                deletedAt: nil
            )
            try insert(entry)
            
            // Insert Q&A pairs
            for (index, qa) in qas.enumerated() {
                let sql = "INSERT INTO reflection_qas (entry_id, position, question, answer) VALUES (?, ?, ?, ?);"
                try db.run(sql, entry.id, index, qa.0, qa.1)
            }
            
            return entry
        }
    }
    
    func updateReflectionQAs(entryId: String, items: [(id: Int64?, question: String, answer: String)]) throws {
        try queue.sync {
            // Delete existing Q&As
            let deleteSQL = "DELETE FROM reflection_qas WHERE entry_id = ?;"
            try db.run(deleteSQL, entryId)
            
            // Insert new Q&As
            for (index, item) in items.enumerated() {
                let sql = "INSERT INTO reflection_qas (entry_id, position, question, answer) VALUES (?, ?, ?, ?);"
                try db.run(sql, entryId, index, item.question, item.answer)
            }
            
            // Update entry timestamp
            let updateSQL = "UPDATE entries SET updated_at = ? WHERE id = ?;"
            try db.run(updateSQL, isoString(Date()), entryId)
        }
    }

    // MARK: - Private helpers
    private func insert(_ entry: Entry) throws {
        let sql = "INSERT OR REPLACE INTO entries (id, user_id, type, title, text, tags, created_at, updated_at, deleted_at) VALUES (?,?,?,?,?,?,?,?,?);"
        let tagsData = try? JSONEncoder().encode(entry.tags)
        let tagsJSON = tagsData.flatMap { String(data: $0, encoding: .utf8) }
        try db.run(sql, entry.id, entry.userId, entry.type.rawValue, entry.title, entry.text, tagsJSON, isoString(entry.createdAt), isoString(entry.updatedAt), entry.deletedAt.map(isoString))
    }
    
    func updateEntryDate(id: String, createdAt: Date) throws {
        try queue.sync {
            let sql = "UPDATE entries SET created_at = ? WHERE id = ?;"
            try db.run(sql, isoString(createdAt), id)
        }
    }
}
