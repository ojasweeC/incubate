import SwiftUI

struct NewEntryView: View {
    enum EntryKind: String, CaseIterable { case raw = "Raw", reflection = "Reflection", planning = "Planning" }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedKind: EntryKind = .raw
    @State private var text: String = ""
    @State private var showSavedToast = false
    @State private var showMicAlert = false

    init(selectedType: EntryType? = nil) {
        if let type = selectedType {
            switch type {
            case .raw: _selectedKind = State(initialValue: .raw)
            case .goals: _selectedKind = State(initialValue: .planning)
            case .todos: _selectedKind = State(initialValue: .planning)
            case .voice: _selectedKind = State(initialValue: .raw)
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("Type", selection: $selectedKind) {
                ForEach(EntryKind.allCases, id: \.self) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)

            SoftCard {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Write here…")
                            .foregroundColor(AppColors.seaMoss)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $text)
                        .frame(minHeight: 220)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.ink)
                }
            }

            if selectedKind == .raw {
                Button {
                    showMicAlert = true
                } label: {
                    Label("Voice (mock)", systemImage: "mic")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BeigePillButtonStyle())
                .accessibilityLabel("Voice recording (mock)")
            }

            Spacer()
        }
        .padding(16)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }
                    .accessibilityLabel("Save entry")
            }
        }
        .alert("Saved (mock)", isPresented: $showSavedToast) {
            Button("OK", role: .cancel) { dismiss() }
        }
        .alert("Voice recording not implemented", isPresented: $showMicAlert) {
            Button("OK", role: .cancel) {}
        }
        .navigationTitle("New Entry")
        .background(
            ZStack {
                AppColors.backgroundGradient
                Color.white.opacity(0.9)
            }.ignoresSafeArea()
        )
    }

    private func save() {
        showSavedToast = true
    }
}

struct NewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { NewEntryView() }
    }
}


