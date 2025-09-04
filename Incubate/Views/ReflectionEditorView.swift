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
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            VStack(spacing: 20) {
                                titleSection
                                qaSection
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(entryId == nil ? "New Reflection" : "Edit Reflection")
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
                        .disabled(
                            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                            qaPairs.allSatisfy { $0.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        )
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
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [AppColors.seaMoss, AppColors.teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var loadingView: some View {
        ProgressView("Loading...")
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundColor(AppColors.seaMoss)
    }
    
    private var titleSection: some View {
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
            
            TextField("Title (optional)", text: $title)
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
    }
    
    private var qaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.seaMoss)
                Text("Questions & Answers")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.seaMoss)
                Spacer()
                Button("Add Q&A") {
                    qaPairs.append(("", ""))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.seaMoss)
            }
            
            ForEach(qaPairs.indices, id: \.self) { index in
                qaItemView(for: index)
            }
        }
    }
    
    private func qaItemView(for index: Int) -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Question")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.seaMoss)
                TextField("Question…", text: $qaPairs[index].question)
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
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Answer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.seaMoss)
                TextEditor(text: $qaPairs[index].answer)
                    .font(.system(size: 16, weight: .regular))
                    .frame(minHeight: 120)
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
                        .foregroundColor(AppColors.seaMoss.opacity(0.7))
                        .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.seaMoss.opacity(0.2), lineWidth: 1)
        )
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
                .map {
                    (question: $0.question.trimmingCharacters(in: .whitespacesAndNewlines),
                     answer: $0.answer.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                .filter { !$0.answer.isEmpty } // Keep entries with answers
            
            if let entryId = entryId {
                // Update existing entry
                try DatabaseManager.shared.updateReflectionQAs(
                    entryId: entryId,
                    items: validQAs.map { (id: nil as Int64?, question: $0.question, answer: $0.answer) }
                )
                // Also update the title
                try DatabaseManager.shared.updateEntryMeta(
                    id: entryId,
                    title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                    text: ""
                )
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
