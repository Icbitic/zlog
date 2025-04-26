import SwiftUI

struct TagsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var tagStore: TagStore
    @Environment(\.editMode) private var editMode
    @State private var tagToEdit: Tag?

    // Dynamic Colors
    private var backgroundColor: Color {
        Color(UIColor.systemGroupedBackground)
    }
    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(UIColor.secondarySystemBackground)
            : Color(UIColor.systemBackground)
    }
    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.1)
            : Color.black.opacity(0.05)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Grouped background
                backgroundColor
                    .ignoresSafeArea()

                List {
                    // Tag Cards with move & delete support
                    ForEach(tagStore.tags) { tag in
                        tagCard(for: tag)
                            .padding(.horizontal)
                            .listRowBackground(Color.clear)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)

                    // Add New Tag Card
                    Button(action: {
                        tagToEdit = Tag(tagName: "", details: "", color: Color.black.toHex())
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add New Tag")
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(cardBackground)
                        .cornerRadius(12)
                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .padding(.top)
            }
            .navigationTitle("Tags")
            .toolbar {
                EditButton()
            }
            // Edit Tag Sheet
            .sheet(item: $tagToEdit) { editable in
                TagEditorView(tag: editable) { updated in
                    if let idx = tagStore.tags.firstIndex(where: { $0.id == updated.id }) {
                        tagStore.tags[idx] = updated
                    } else {
                        tagStore.tags.append(updated)
                    }
                }
            }
        }
    }

    // MARK: - Move & Delete Handlers
    private func delete(at offsets: IndexSet) {
        tagStore.tags.remove(atOffsets: offsets)
    }

    private func move(from source: IndexSet, to destination: Int) {
        tagStore.tags.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Tag Card View
    private func tagCard(for tag: Tag) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: tag.color))
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(tag.tagName.capitalized)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !tag.details.isEmpty {
                    Text(tag.details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: { tagToEdit = tag }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }
}

// Editor remains unchanged
struct TagEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Tag
    let onSave: (Tag) -> Void

    init(tag: Tag, onSave: @escaping (Tag) -> Void) {
        self._draft = State(initialValue: tag)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tag Info")) {
                    TextField("Tag Name", text: $draft.tagName)
                        .textInputAutocapitalization(.words)
                    TextField("Details", text: $draft.details)
                }

                Section(header: Text("Color")) {
                    HStack {
                        ColorPicker("Pick a Color", selection: Binding(
                            get: { Color(hex: draft.color) },
                            set: { draft.color = $0.toHex() }
                        ))
                        Spacer()
                        Circle()
                            .fill(Color(hex: draft.color))
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemBackground))
            .navigationTitle(draft.tagName.isEmpty ? "New Tag" : "Edit Tag")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(draft.tagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview
struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TagsView()
                .environmentObject(TagStore.sampleTagStore)
                .preferredColorScheme(.light)
            TagsView()
                .environmentObject(TagStore.sampleTagStore)
                .preferredColorScheme(.dark)
        }
    }
}
