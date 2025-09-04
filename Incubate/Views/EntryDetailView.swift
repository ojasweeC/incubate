import SwiftUI

struct EntryDetailView: View {
    let entryId: String
    @State private var entryDetail: EntryDetail?
    @State private var isLoading = true
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let detail = entryDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(detail.entry.title ?? "Untitled")
                                .font(.title2)
                                .foregroundColor(AppColors.ink)
                            
                            Text(detail.entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(AppColors.seaMoss)
                        }
                        .padding(.horizontal, 16)
                        
                        // Content based on type
                        switch detail.entry.type {
                        case .raw:
                            rawDetailView(detail)
                        case .todos:
                            todosDetailView(detail)
                        case .goals:
                            goalsDetailView(detail)
                        case .reflection:
                            reflectionDetailView(detail)
                        }
                    }
                    .padding(.vertical, 16)
                }
            } else {
                Text("Entry not found")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            loadEntryDetail()
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
    
    private func rawDetailView(_ detail: EntryDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.headline)
                .foregroundColor(AppColors.ink)
                .padding(.horizontal, 16)
            
            Text(detail.entry.text)
                .foregroundColor(AppColors.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.beige)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 16)
        }
    }
    
    private func todosDetailView(_ detail: EntryDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)
                .foregroundColor(AppColors.ink)
                .padding(.horizontal, 16)
            
            if let todoItems = detail.todoItems {
                ForEach(todoItems) { item in
                    HStack {
                        Button {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            toggleTodoItem(item)
                        } label: {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isDone ? AppColors.seaMoss : AppColors.seaMoss.opacity(0.5))
                                .font(.title2)
                                .scaleEffect(item.isDone ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: item.isDone)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(item.text)
                            .foregroundColor(item.isDone ? AppColors.ink.opacity(0.6) : AppColors.ink)
                            .strikethrough(item.isDone)
                            .animation(.easeInOut(duration: 0.2), value: item.isDone)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.beige)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    private func goalsDetailView(_ detail: EntryDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bullets")
                .font(.headline)
                .foregroundColor(AppColors.ink)
                .padding(.horizontal, 16)
            
            if let goalItems = detail.goalItems {
                ForEach(goalItems) { item in
                    HStack {
                        Text("•")
                            .foregroundColor(AppColors.seaMoss)
                            .font(.title2)
                        
                        Text(item.bullet)
                            .foregroundColor(AppColors.ink)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.beige)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    private func reflectionDetailView(_ detail: EntryDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Questions & Answers")
                .font(.headline)
                .foregroundColor(AppColors.ink)
                .padding(.horizontal, 16)
            
            if let reflectionQAs = detail.reflectionQAs {
                ForEach(reflectionQAs) { qa in
                    VStack(alignment: .leading, spacing: 8) {
                        if !qa.question.isEmpty {
                            Text("Q: \(qa.question)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.seaMoss)
                        }
                        
                        Text("A: \(qa.answer)")
                            .foregroundColor(AppColors.ink)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.beige)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    private func loadEntryDetail() {
        isLoading = true
        do {
            entryDetail = try DatabaseManager.shared.fetchEntryDetail(id: entryId)
        } catch {
            print("Failed to fetch entry detail: \(error)")
            entryDetail = nil
        }
        isLoading = false
    }
    
    private func toggleTodoItem(_ item: TodoItem) {
        // Update UI state immediately for better responsiveness
        if var detail = entryDetail, let todoItems = detail.todoItems {
            if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                var updatedTodoItems = todoItems
                updatedTodoItems[index] = TodoItem(
                    id: item.id,
                    entryId: item.entryId,
                    position: item.position,
                    text: item.text,
                    isDone: !item.isDone
                )
                entryDetail = EntryDetail(
                    entry: detail.entry,
                    todoItems: updatedTodoItems,
                    goalItems: detail.goalItems,
                    reflectionQAs: detail.reflectionQAs
                )
            }
        }
        
        // Update database in background
        Task {
            do {
                print("🔄 Toggling todo item \(item.id) from \(item.isDone) to \(!item.isDone)")
                try DatabaseManager.shared.updateTodoItem(id: item.id, isDone: !item.isDone)
                print("✅ Successfully updated todo item in database")
            } catch {
                print("❌ Failed to update todo item: \(error)")
                // Revert UI state if database update failed
                await MainActor.run {
                    loadEntryDetail()
                }
            }
        }
    }
    
    private func deleteEntry() {
        do {
            try DatabaseManager.shared.softDeleteEntry(id: entryId)
            dismiss()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}

struct EntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EntryDetailView(entryId: "preview")
        }
    }
}
