import SwiftUI

struct GoalsEditorView: View {
    let entryId: String? // nil for new entries, non-nil for editing
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var bullets: [String] = [""]
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
                }
            }
            .navigationTitle(entryId == nil ? "New Goal Setting" : "Edit Goal Setting")
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
                if let goalItems = entryDetail.goalItems {
                    bullets = goalItems.map { $0.bullet }
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
            let validBullets = bullets
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if let entryId = entryId {
                // Update existing entry
                try DatabaseManager.shared.updateGoalItems(
                    entryId: entryId,
                    items: validBullets.map { (id: nil as Int64?, bullet: $0) }
                )
            } else {
                // Create new entry
                _ = try DatabaseManager.shared.saveNewGoals(
                    title: trimmedTitle,
                    bullets: validBullets
                )
            }
            
            showingSaveAlert = true
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}

struct GoalsEditorView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsEditorView()
    }
}
