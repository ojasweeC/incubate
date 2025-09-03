import SwiftUI

struct RawEditorView: View {
    let entryId: String? // nil for new entries, non-nil for editing
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var entryBody: String = ""
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
                            TextEditor(text: $entryBody)
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
                }
            }
            .navigationTitle(entryId == nil ? "New Raw Entry" : "Edit Entry")
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
                entryBody = entryDetail.entry.text
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
            let trimmedBody = entryBody.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let entryId = entryId {
                // Update existing entry
                try DatabaseManager.shared.updateEntryMeta(
                    id: entryId,
                    title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                    text: trimmedBody
                )
            } else {
                // Create new entry
                _ = try DatabaseManager.shared.saveNewRaw(
                    title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                    body: trimmedBody
                )
            }
            showingSaveAlert = true
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

struct RawEditorView_Previews: PreviewProvider {
    static var previews: some View {
        RawEditorView()
    }
}
