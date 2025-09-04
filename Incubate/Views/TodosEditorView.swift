import SwiftUI

struct TodosEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var items: [(text: String, isDone: Bool)] = [("", false)]
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 20) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "textformat")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Title")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                                Text("optional")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Enter title...", text: $title)
                                .font(.system(size: 16, weight: .regular))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .foregroundColor(AppColors.ink)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(AppColors.seaMoss.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Items Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checklist")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Items")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                                Button("Add Item") {
                                    items.append(("", false))
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.seaMoss)
                            }
                            
                            ForEach(items.indices, id: \.self) { index in
                                HStack(spacing: 12) {
                                    Button {
                                        items[index].isDone.toggle()
                                    } label: {
                                        Image(systemName: items[index].isDone ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(items[index].isDone ? AppColors.seaMoss : AppColors.seaMoss.opacity(0.5))
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    TextField("Enter item...", text: $items[index].text)
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .foregroundColor(AppColors.ink)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(AppColors.seaMoss.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    if items.count > 1 {
                                        Button {
                                            items.remove(at: index)
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(AppColors.seaMoss.opacity(0.7))
                                                .font(.title2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("To-Do List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.seaMoss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .foregroundColor(AppColors.seaMoss)
                        .fontWeight(.semibold)
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
