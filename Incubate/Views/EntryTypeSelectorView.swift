import SwiftUI

struct EntryTypeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: EntryType?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What kind of entry are you writing?")
                    .font(.title2)
                    .foregroundColor(AppColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                
                VStack(spacing: 16) {
                    entryTypeButton(.raw, title: "Raw", subtitle: "Free-form thoughts and notes")
                    entryTypeButton(.todos, title: "To-Do's", subtitle: "Organized task lists")
                    entryTypeButton(.goals, title: "Goal Setting", subtitle: "Future planning and aspirations")
                    entryTypeButton(.reflection, title: "Reflection", subtitle: "Questions and answers for self-reflection")
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(item: $selectedType) { type in
                switch type {
                case .raw:
                    RawEditorView()
                case .todos:
                    TodosEditorView()
                case .goals:
                    GoalsEditorView()
                case .reflection:
                    ReflectionEditorView()
                }
            }
        }
    }
    
    private func entryTypeButton(_ type: EntryType, title: String, subtitle: String) -> some View {
        Button {
            selectedType = type
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.seaMoss)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.seaMoss)
            }
            .padding(16)
            .background(AppColors.beige)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EntryTypeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        EntryTypeSelectorView()
    }
}
