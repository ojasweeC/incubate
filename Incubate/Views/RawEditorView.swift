import SwiftUI

struct RawEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var entryBody: String = ""   // <-- renamed
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title (optional)")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    TextField("Enter title...", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    Text(Date(), style: .date)
                        .foregroundColor(AppColors.seaMoss)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.beige)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Body")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    TextEditor(text: $entryBody)         // <-- updated binding
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(AppColors.beige)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.seaMoss.opacity(0.3), lineWidth: 1)
                        )
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Raw Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
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
