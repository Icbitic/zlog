import Foundation

@MainActor
class TagStore: ObservableObject {
    @Published var tags: [Tag] = [] {
        didSet {
            // Trigger save whenever 'tags' is changed
            Task {
                if tags.isEmpty || tags == Tag.sampleTags {
                    return
                }
                do {
                    try await save(tags: tags)
                    print("Data saved.")
                } catch {
                    print("Failed to save tags: \(error)")
                }
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("tags.data")
    }
    
    func load() async throws {
        let task = Task<[Tag], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                print("unable to open files")
                return []
            }
            let tags = try JSONDecoder().decode([Tag].self, from: data)
            print(data)
            return tags
        }
        let tags = try await task.value
        print(tags)
        self.tags = tags
        print("previous data loaded")
    }
    
    func save(tags: [Tag]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(tags)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    init(tags: [Tag] = Tag.sampleTags) {
        self.tags = tags
    }
}

extension TagStore {
    static let sampleTagStore = TagStore()
}
