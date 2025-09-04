import SwiftUI

struct GoalsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bullets: [String] = [""]
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 20) {
                        // Category Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "target")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Category")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                                Text("optional")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Enter category...", text: $title)
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
                        
                        // Bullets Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Goals")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                                Button("Add Goal") {
                                    bullets.append("")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.seaMoss)
                            }
                            
                            ForEach(bullets.indices, id: \.self) { index in
                                HStack(spacing: 12) {
                                    Text("•")
                                        .foregroundColor(AppColors.seaMoss)
                                        .font(.title2)
                                    
                                    TextField("Enter goal...", text: $bullets[index])
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
                                    
                                    if bullets.count > 1 {
                                        Button {
                                            bullets.remove(at: index)
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
            .navigationTitle("Goal Setting")
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
