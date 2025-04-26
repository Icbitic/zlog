import SwiftUI

struct StatsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: SleepStore
    @EnvironmentObject var tags: TagStore

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

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Total Sleeps Card
                        statCard(title: "Total Sleeps", value: "\(store.sleeps.count)", unit: "sleeps")

                        // Total Dreams Card
                        statCard(title: "Total Dreams", value: "\(totalDreamsCount())", unit: "dreams")

                        // Most Frequent Tags Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Most Frequent Tags")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            if tags.tags.isEmpty {
                                Text("No tags available")
                                    .italic()
                            } else {
                                ForEach(mostFrequentTags(), id: \.tagName) { tag in
                                    tagRow(tag: tag)
                                }
                            }
                        }
                        .padding()
                        .background(cardBackground)
                        .cornerRadius(12)
                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Stats")
        }
    }

    // MARK: - Stat Card

    private func statCard(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tag Row

    private func tagRow(tag: Tag) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: tag.color))
                .frame(width: 20, height: 20)

            Text(tag.tagName)
                .fontWeight(.medium)

            Spacer()

            Text("\(tagCount(for: tag))×")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    func totalDreamsCount() -> Int {
        store.sleeps.reduce(0) { $0 + $1.dreams.count }
    }

    func mostFrequentTags() -> [Tag] {
        var counts: [Tag: Int] = [:]
        for sleep in store.sleeps {
            for dream in sleep.dreams {
                for tag in dream.tags {
                    counts[tag, default: 0] += 1
                }
            }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    func tagCount(for tag: Tag) -> Int {
        store.sleeps.reduce(0) { sum, sleep in
            sum + sleep.dreams.filter { $0.tags.contains(tag) }.count
        }
    }
}

// Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatsView()
                .environmentObject(SleepStore.sampleSleepStore)
                .environmentObject(TagStore.sampleTagStore)
                .preferredColorScheme(.light)
            StatsView()
                .environmentObject(SleepStore.sampleSleepStore)
                .environmentObject(TagStore.sampleTagStore)
                .preferredColorScheme(.dark)
        }
    }
}
