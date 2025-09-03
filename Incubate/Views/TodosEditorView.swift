import SwiftUI

struct TodosEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var items: [(text: String, isDone: Bool)] = [("", false)]
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("To-Do List")
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
        }
    }
    
    private func saveEntry() {
        do {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let validItems = items
                .map { (text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), isDone: $0.isDone) }
                .filter { !$0.text.isEmpty }
            
            _ = try DatabaseManager.shared.saveNewTodos(
                title: trimmedTitle,
                items: validItems
            )
            
            showingSaveAlert = true
        } catch {
            print("Failed to save todos entry: \(error)")
        }
    }
}

struct TodosEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TodosEditorView()
    }
}
