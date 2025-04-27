import SwiftUI

struct ReadingView: View {
    @EnvironmentObject var store: SleepStore
    @Environment(\.colorScheme) var colorScheme
    
    // State
    @State private var currentDream: Dream? = nil
    @State private var useRemote: Bool = false
    @State private var serverDreams: [Dream] = []
    @State private var isLoadingRemote: Bool = false
    @State private var errorMessage: String? = nil
    
    // Dynamic Colors
    private var backgroundColor: Color { Color(UIColor.systemGroupedBackground) }
    private var cardBackground: Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground)
    }
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Source Toggle
                        Picker("Source", selection: $useRemote) {
                            Label("Local", systemImage: "folder").tag(false)
                            Label("Server", systemImage: "cloud").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Error or Loading
                        if let msg = errorMessage {
                            Text(msg)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else if useRemote && isLoadingRemote {
                            ProgressView("Loading...")
                                .padding(.horizontal)
                        }
                        
                        // Dream Card
                        if let dream = currentDream {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(dream.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(dream.description)
                                    .foregroundColor(.secondary)
                                
                                if !dream.tags.isEmpty {
                                    HStack(spacing: 8) {
                                        ForEach(dream.tags, id: \.id) { tag in
                                            Text(tag.tagName)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(hex: tag.color).opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                // Share Button
                                Button(action: shareDream) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Dream")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(cardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                                    .padding(.top)
                                }
                                .disabled(useRemote || dream.isUploaded)
                                
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        } else {
                            Text("No dreams available.")
                                .foregroundColor(.secondary)
                                .italic()
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Randomize Button
                        Button(action: pickRandom) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Random Dream")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        .disabled(useRemote && serverDreams.isEmpty)
                        .padding(.bottom)
                    }
                    .padding(.top)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Read Dreams")
            .onAppear {
                pickRandom()
            }
            .onChange(of: useRemote) { remote in
                if remote {
                    fetchRemoteDreams()
                } else {
                    currentDream = store.sleeps.flatMap { $0.dreams }.randomElement()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func pickRandom() {
        if useRemote {
            if serverDreams.isEmpty {
                fetchRemoteDreams()
            } else {
                currentDream = serverDreams.randomElement()
            }
        } else {
            currentDream = store.sleeps.flatMap { $0.dreams }.randomElement()
        }
    }
    
    private func fetchRemoteDreams() {
        guard let url = URL(string: "http://localhost:8080/api/dreams") else { return }
        isLoadingRemote = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingRemote = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else if let data = data,
                          let decoded = try? JSONDecoder().decode([Dream].self, from: data) {
                    serverDreams = decoded
                    currentDream = decoded.randomElement()
                } else {
                    errorMessage = "Failed to load dreams"
                }
            }
        }.resume()
    }
    
    private func shareDream() {
        guard let dream = currentDream,
              let url = URL(string: "http://localhost:8080/api/dreams") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let body = try? JSONEncoder().encode(dream) else { return }
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    // mark as uploaded
                    for sleep in store.sleeps.indices {
                        if let idx = store.sleeps[sleep].dreams.firstIndex(where: { $0.id == dream.id }) {
                            store.sleeps[sleep].dreams[idx].isUploaded = true
                        }
                    }
                    currentDream?.isUploaded = true
                }
            }
        }.resume()
    }
}

struct ReadingView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingView()
            .environmentObject(SleepStore.sampleSleepStore)
            .preferredColorScheme(.light)
        ReadingView()
            .environmentObject(SleepStore.sampleSleepStore)
            .preferredColorScheme(.dark)
    }
}
