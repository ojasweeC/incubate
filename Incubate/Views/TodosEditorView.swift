import SwiftUI

struct TodosEditorView: View {
    let entryId: String? // nil for new entries, non-nil for editing
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var items: [(text: String, isDone: Bool)] = [("", false)]
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    
    init(entryId: String? = nil) {
        self.entryId = entryId
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(AppColors.ink)
                            TextField("Enter title...", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Items")
                                    .font(.headline)
                                    .foregroundColor(AppColors.ink)
                                Spacer()
                                Button("Add Item") {
                                    items.append(("", false))
                                }
                                .buttonStyle(BeigePillButtonStyle())
                            }
                            
                            ForEach(items.indices, id: \.self) { index in
                                HStack {
                                    Button {
                                        items[index].isDone.toggle()
                                    } label: {
                                        Image(systemName: items[index].isDone ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(items[index].isDone ? AppColors.seaMoss : AppColors.ink)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    TextField("Enter item...", text: $items[index].text)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    if items.count > 1 {
                                        Button {
                                            items.remove(at: index)
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationTitle(entryId == nil ? "New To-Do List" : "Edit To-Do List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                items.allSatisfy { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                }
            }
            .alert("Entry Saved", isPresented: $showingSaveAlert) {
                Button("OK") { dismiss() }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let entryId = entryId {
                    loadExistingEntry(entryId)
                } else {
                    isLoading = false
                }
            }
        }
    }
    
    private func loadExistingEntry(_ id: String) {
        isLoading = true
        do {
            if let entryDetail = try DatabaseManager.shared.fetchEntryDetail(id: id) {
                title = entryDetail.entry.title ?? ""
                if let todoItems = entryDetail.todoItems {
                    items = todoItems.map { ($0.text, $0.isDone) }
                }
            }
        } catch {
            errorMessage = "Failed to load entry: \(error.localizedDescription)"
            showingErrorAlert = true
        }
        isLoading = false
    }
    
    private func saveEntry() {
        do {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let validItems = items
                .map { (text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), isDone: $0.isDone) }
                .filter { !$0.text.isEmpty }
            
            if let entryId = entryId {
                // Update existing entry
                try DatabaseManager.shared.updateTodoItems(
                    entryId: entryId,
                    items: validItems.map { (id: nil as Int64?, text: $0.text, isDone: $0.isDone) }
                )
            } else {
                // Create new entry
                _ = try DatabaseManager.shared.saveNewTodos(
                    title: trimmedTitle,
                    items: validItems
                )
            }
            
            showingSaveAlert = true
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

struct TodosEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TodosEditorView()
    }
}
