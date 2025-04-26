import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            JournalView()
                .tabItem {
                    Image(systemName: "highlighter")
                    Text("Journal")
                }

            TagsView()
                .tabItem {
                    Image(systemName: "tag.fill")
                    Text("Tags")
                }

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            
            ReadingView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Reading")
                }
        }
    }
}

struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SleepStore.sampleSleepStore)
            .environmentObject(TagStore.sampleTagStore)
    }
}
