import SwiftUI

struct GoalsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bullets: [String] = [""]
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    TextField("Enter category...", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Bullets")
                            .font(.headline)
                            .foregroundColor(AppColors.ink)
                        Spacer()
                        Button("Add Bullet") {
                            bullets.append("")
                        }
                        .buttonStyle(BeigePillButtonStyle())
                    }
                    
                    ForEach(bullets.indices, id: \.self) { index in
                        HStack {
                            Text("•")
                                .foregroundColor(AppColors.seaMoss)
                                .font(.title2)
                            
                            TextField("Enter bullet point...", text: $bullets[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if bullets.count > 1 {
                                Button {
                                    bullets.remove(at: index)
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
            .navigationTitle("Goal Setting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                                bullets.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
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
            let validBullets = bullets
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            _ = try DatabaseManager.shared.saveNewGoals(
                title: trimmedTitle,
                bullets: validBullets
            )
            
            showingSaveAlert = true
        } catch {
            print("Failed to save goals entry: \(error)")
        }
    }
}

struct GoalsEditorView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsEditorView()
    }
}
