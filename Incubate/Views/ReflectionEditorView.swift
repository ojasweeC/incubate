import SwiftUI

struct ReflectionEditorView: View {
    let entryId: String? // nil for new entries, non-nil for editing
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var qaPairs: [(question: String, answer: String)] = [("", "")]
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
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.headline)
                                    .foregroundColor(AppColors.ink)
                                TextField("Title (optional)", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Questions & Answers")
                                        .font(.headline)
                                        .foregroundColor(AppColors.ink)
                                    Spacer()
                                    Button("Add Q&A") {
                                        qaPairs.append(("", ""))
                                    }
                                    .buttonStyle(BeigePillButtonStyle())
                                }
                                
                                ForEach(qaPairs.indices, id: \.self) { index in
                                    VStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Question")
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.ink)
                                            TextField("Question…", text: $qaPairs[index].question)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Answer")
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.ink)
                                            TextEditor(text: $qaPairs[index].answer)
                                                .frame(minHeight: 80)
                                                .padding(8)
                                                .background(Color(UIColor.systemGray6))
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                                )
                                        }
                                        
                                        if qaPairs.count > 1 {
                                            HStack {
                                                Spacer()
                                                Button {
                                                    qaPairs.remove(at: index)
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "minus.circle")
                                                        Text("Remove")
                                                    }
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(UIColor.systemGray6).opacity(0.3))
                                    .cornerRadius(12)
                                }
                            }
                            
                            Spacer(minLength: 20)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(entryId == nil ? "New Reflection" : "Edit Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                                qaPairs.allSatisfy { $0.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
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
                if let reflectionQAs = entryDetail.reflectionQAs {
                    qaPairs = reflectionQAs.map { ($0.question, $0.answer) }
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
            let validQAs = qaPairs
                .map { (question: $0.question.trimmingCharacters(in: .whitespacesAndNewlines), 
                       answer: $0.answer.trimmingCharacters(in: .whitespacesAndNewlines)) }
                .filter { !$0.answer.isEmpty } // Keep entries with answers
            
            if let entryId = entryId {
                // Update existing entry
                try DatabaseManager.shared.updateReflectionQAs(
                    entryId: entryId,
                    items: validQAs.map { (id: nil as Int64?, question: $0.question, answer: $0.answer) }
                )
                // Also update the title
                try DatabaseManager.shared.updateEntryMeta(id: entryId, title: trimmedTitle.isEmpty ? nil : trimmedTitle, text: "")
            } else {
                // Create new entry
                _ = try DatabaseManager.shared.saveNewReflection(
                    title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                    qas: validQAs.map { ($0.question, $0.answer) }
                )
            }
            
            showingSaveAlert = true
            print("Reflection entry saved successfully")
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
}
