import SwiftUI

@main
struct zlogApp: App {
    @StateObject private var store: SleepStore = SleepStore()
    @StateObject private var tags: TagStore = TagStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    do {
                        try await store.load()
                    } catch {
                        store.sleeps = []
                    }
                }
                .task {
                    do {
                        try await tags.load()
                    } catch {
                        tags.tags = Tag.sampleTags
                    }
                }
                .environmentObject(store)
                .environmentObject(tags)
        }
    }
}
