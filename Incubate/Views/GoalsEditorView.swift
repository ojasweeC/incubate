import SwiftUI

struct GoalsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bullets: [String] = [""]
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
                    // Category Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        TextField("Enter category...", text: $title)
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
                    
                    // Bullets Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Bullets")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Spacer()
                            Button("Add Bullet") {
                                bullets.append("")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.seaMoss)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        
                        ForEach(bullets.indices, id: \.self) { index in
                            HStack(spacing: 12) {
                                Text("•")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                TextField("Enter bullet point...", text: $bullets[index])
                                    .padding(12)
                                    .background(Color.white)
                                    .foregroundColor(AppColors.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                
                                if bullets.count > 1 {
                                    Button {
                                        bullets.remove(at: index)
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
                .navigationTitle("Goal Setting")
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
                                    bullets.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
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
