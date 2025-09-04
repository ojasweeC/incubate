import SwiftUI

struct EntriesListView: View {
    let entryType: EntryType
    @State private var entries: [Entry] = []
    @State private var isLoading = true
    @State private var showingEditor = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if entries.isEmpty {
                    Text("No \(entryType.title.lowercased()) yet")
                        .foregroundColor(AppColors.seaMoss)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(entries) { entry in
                        NavigationLink {
                            EntryDetailView(entryId: entry.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title ?? entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.headline)
                                    .foregroundColor(AppColors.ink)
                                
                                Text(secondaryText(for: entry))
                                    .font(.caption)
                                    .foregroundColor(AppColors.seaMoss)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.beige.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .navigationTitle(entryType.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.seaMoss)
                }
                .accessibilityLabel("Add new \(entryType.title.lowercased())")
            }
        }
        .sheet(isPresented: $showingEditor) {
            editorViewForEntryType
        }
        .onAppear {
            loadEntries()
        }
        .refreshable {
            loadEntries()
        }
    }
    
    private func loadEntries() {
        isLoading = true
        do {
            entries = try DatabaseManager.shared.fetchByType(type: entryType)
        } catch {
            print("Failed to fetch entries: \(error)")
            entries = []
        }
        isLoading = false
    }
    
    private func secondaryText(for entry: Entry) -> String {
        switch entry.type {
        case .raw:
            let preview = entry.text.prefix(40)
            return preview.count == 40 ? "\(preview)..." : String(preview)
        case .todos:
            // This would need to fetch todo items to count them
            return "Tap to view items"
        case .goals:
            // This would need to fetch goal items to count them
            return "Tap to view bullets"
        case .reflection:
            return "Reflect with Inky"
        }
    }
    
    @ViewBuilder
    private var editorViewForEntryType: some View {
        switch entryType {
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

struct EntriesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EntriesListView(entryType: .raw)
        }
    }
}
