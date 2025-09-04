import SwiftUI

struct RawEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var entryBody: String = ""   // <-- renamed
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
                            
                            TextField("What's on your mind?", text: $title)
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
                        
                        // Date Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                            }
                            
                            HStack {
                                Text(Date(), style: .date)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(AppColors.ink)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppColors.seaMoss.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Body Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Text("Content")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.seaMoss)
                                Spacer()
                            }
                            
                            TextEditor(text: $entryBody)
                                .font(.system(size: 16, weight: .regular))
                                .frame(minHeight: 300)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .foregroundColor(AppColors.ink)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(AppColors.seaMoss.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Raw Entry")
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
                        .disabled(entryBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            let trimmedBody = entryBody.trimmingCharacters(in: .whitespacesAndNewlines)   // <-- updated
            
            _ = try DatabaseManager.shared.saveNewRaw(
                title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                body: trimmedBody
            )
            showingSaveAlert = true
        } catch {
            print("Failed to save raw entry: \(error)")
        }
    }
}

struct RawEditorView_Previews: PreviewProvider {
    static var previews: some View {
        RawEditorView()
    }
}
