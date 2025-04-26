import SwiftUI

struct JournalView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: SleepStore
    
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    var iconColor: Color {
        colorScheme == .dark ? .white : .blue
    }
    
    // Filtered indices based on search text
    private var filteredIndices: [Int] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            return Array(store.sleeps.indices)
        }
        let lower = query.lowercased()
        return store.sleeps.indices.filter { idx in
            let sleep = store.sleeps[idx]
            if sleep.notes.lowercased().contains(lower) { return true }
            return sleep.dreams.contains { dream in
                dream.title.lowercased().contains(lower) ||
                dream.description.lowercased().contains(lower)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Grouped background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(filteredIndices, id: \.self) { index in
                            let binding = $store.sleeps[index]
                            NavigationLink(
                                destination: DetailedSleepView(
                                    sleep: binding,
                                    removeAction: { store.sleeps.remove(at: index) }
                                )
                            ) {
                                SleepCardView(sleep: binding)
                                    .padding()
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        }

                        // Add New Dream Card
                        Button(action: {
                            // Create a new sleep and present the edit sheet
                            store.sleeps.append(Sleep())
                        }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .font(.title2)
                                Text("Add New Dream")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                    .padding(.top)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Journal")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer,
                prompt: "Search notes, dream titles, or descriptions"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.sleeps.append(Sleep())
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(iconColor)
                    }
                }
            }
        }
        .onChange(of: isSearchActive) { active in
            if !active { searchText = "" }
        }
    }
}

struct JournalViewPreview: PreviewProvider {
    static var previews: some View {
        JournalView()
            .environmentObject(SleepStore.sampleSleepStore)
            .preferredColorScheme(.light)
    }
}
