import SwiftUI

struct DetailedSleepView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: SleepStore
    @EnvironmentObject var tagStore: TagStore
    @Binding var sleep: Sleep
    var removeAction: () -> Void // Keep the removeAction
    @Environment(\.dismiss) var dismiss // Add this

    @State private var isEditingSleep = false
    @State private var dreamToEdit: Dream?
    @State private var showingConfirmationDialog = false

    // Dynamic Colors
    private var backgroundColor: Color { Color(UIColor.systemGroupedBackground) }
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Sleep Details
                VStack(alignment: .leading) {
                    HStack {
                        Text("Sleep Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Edit") { isEditingSleep = true }
                    }
                    Text("Date: \(sleep.detailedDescription)")
                        .foregroundColor(.secondary)
                    TextEditor(text: $sleep.notes)
                        .frame(minHeight: 100)
                        .background(cardBackground)
                        .cornerRadius(8)
                }
                .padding()
                .background(cardBackground)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)

                // Dreams
                VStack(alignment: .leading) {
                    HStack {
                        Text("Dreams")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Add Dream") {
                            dreamToEdit = Dream(title: "", description: "", tags: [], dreamType: .normal, isFavorite: false, rating: .neutral)
                        }
                    }

                    if sleep.dreams.isEmpty {
                        Text("No dreams recorded for this sleep.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach($sleep.dreams) { $dream in
                            DreamCard(dream: $dream)
                                .onTapGesture { dreamToEdit = $dream.wrappedValue }
                        }
                    }
                }
                .padding()
                .background(cardBackground)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)

                // Delete Button
                Button(role: .destructive, action: {
                    showingConfirmationDialog = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Sleep")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(cardBackground)
                .cornerRadius(12)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
            }
            .padding()
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("Sleep on \(sleep.abbreviatedDescription)")
        .sheet(isPresented: $isEditingSleep) {
            EditSleepView(sleep: $sleep)
        }
        .sheet(item: $dreamToEdit) { dream in
            EditDreamView(dream: dream) { updatedDream in
                if let index = sleep.dreams.firstIndex(where: { $0.id == updatedDream.id }) {
                    sleep.dreams[index] = updatedDream
                } else {
                    sleep.dreams.append(updatedDream)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this sleep?",
            isPresented: $showingConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                removeAction()
                dismiss() // Dismiss the current view after deletion
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

//MARK: - Dream Card

struct DreamCard: View {
    @Binding var dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dream.title)
                .font(.headline)
            Text(dream.description)
                .foregroundColor(.secondary)
            TagListView(tags: dream.tags)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

//MARK: - Tag List View

struct TagListView: View {
    let tags: [Tag]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    HStack {
                        Circle()
                            .fill(Color(hex: tag.color))
                            .frame(width: 8, height: 8)
                        Text(tag.tagName)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: tag.color).opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
}

//MARK: - Edit Sleep View

struct EditSleepView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sleep: Sleep

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $sleep.date)
                TextEditor(text: $sleep.notes)
                    .frame(minHeight: 100)
            }
            .navigationTitle("Edit Sleep")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemBackground))
        }
    }
}

//MARK: - Edit Dream View

struct EditDreamView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tagStore: TagStore
    @State private var draft: Dream
    let onSave: (Dream) -> Void

    init(dream: Dream, onSave: @escaping (Dream) -> Void) {
        self._draft = State(initialValue: dream)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dream Details") {
                    TextField("Title", text: $draft.title)
                    TextEditor(text: $draft.description)
                        .frame(minHeight: 100)
                }

                Section("Tags") {
                    TagPicker(selection: $draft.tags)
                }

                Section("Type & Rating") {
                    Picker("Type", selection: $draft.dreamType) {
                        ForEach(DreamType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }

                    Picker("Rating", selection: $draft.rating) {
                        ForEach(DreamRating.allCases, id: \.self) { rating in
                            Text(rating.label).tag(rating)
                        }
                    }
                }

                Section {
                    Toggle("Favorite", isOn: $draft.isFavorite)
                }
            }
            .navigationTitle(draft.title.isEmpty ? "New Dream" : "Edit Dream")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemBackground))
        }
    }
}

//MARK: - Tag Picker

struct TagPicker: View {
    @EnvironmentObject var tagStore: TagStore
    @Binding var selection: [Tag]

    var body: some View {
        List {
            ForEach(tagStore.tags) { tag in
                Button(action: { toggleTag(tag) }) {
                    HStack {
                        Circle()
                            .fill(Color(hex: tag.color))
                            .frame(width: 8, height: 8)
                        Text(tag.tagName)
                        Spacer()
                        if selection.contains(tag) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .frame(height: 200)
    }

    private func toggleTag(_ tag: Tag) {
        if selection.contains(tag) {
            selection.removeAll(where: { $0 == tag })
        } else {
            selection.append(tag)
        }
    }
}

struct DetailedSleepView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSleep = Sleep.sampleSleep[0]
        NavigationView {
            DetailedSleepView(sleep: .constant(sampleSleep), removeAction: { })
                .environmentObject(SleepStore.sampleSleepStore)
                .environmentObject(TagStore.sampleTagStore)
        }
    }
}

