import SwiftUI

struct TodosEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var items: [(text: String, isDone: Bool)] = [("", false)]
    @State private var showingSaveAlert = false
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                colors: [AppColors.seaMoss, AppColors.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            NavigationStack {
                VStack(spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        TextField("Enter title...", text: $title)
                            .padding(16)
                            .background(Color.white)
                            .foregroundColor(AppColors.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppColors.ink.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Items Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Items")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Spacer()
                            Button("Add Item") {
                                items.append(("", false))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.seaMoss)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        
                        ForEach(items.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                Button {
                                    items[index].isDone.toggle()
                                } label: {
                                    Image(systemName: items[index].isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(items[index].isDone ? AppColors.seaMoss : .white)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField("Enter item...", text: $items[index].text)
                                    .padding(12)
                                    .background(Color.white)
                                    .foregroundColor(AppColors.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                
                                if items.count > 1 {
                                    Button {
                                        items.remove(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                }
                .padding(.top, 20)
                .navigationTitle("To-Do List")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveEntry() }
                            .foregroundColor(.white)
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                    items.allSatisfy { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                    }
                }
                .alert("Entry Saved", isPresented: $showingSaveAlert) {
                    Button("OK") { dismiss() }
                }
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
