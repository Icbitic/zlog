import Foundation

@MainActor
class SleepStore: ObservableObject {
    @Published var sleeps: [Sleep] = [] {
        didSet {
            // Trigger save whenever 'sleeps' is changed
            Task {
                if sleeps.isEmpty {
                    return
                }
                do {
                    try await save(sleeps: sleeps)
                    print("Data saved.")
                } catch {
                    print("Failed to save sleeps: \(error)")
                }
            }
        }
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("sleeps.data")
    }
    
    func load() async throws {
        let task = Task<[Sleep], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                print("unable to open files")
                return []
            }
            let sleeps = try JSONDecoder().decode([Sleep].self, from: data)
            print(data)
            return sleeps
        }
        let sleeps = try await task.value
        print(sleeps)
        self.sleeps = sleeps
        print("previous data loaded")
    }
    
    func save(sleeps: [Sleep]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(sleeps)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    init(sleeps: [Sleep] = []) {
        self.sleeps = sleeps
    }
}

extension SleepStore {
    static let sampleSleepStore = SleepStore(sleeps: Sleep.sampleSleep)
}
