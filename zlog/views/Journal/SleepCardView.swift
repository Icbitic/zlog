import SwiftUI

struct SleepCardView: View {
    @Binding var sleep: Sleep
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sleep.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
            
            Text(sleep.notes.isEmpty ? "No notes" : sleep.notes)
                .font(.subheadline)
                .foregroundColor(sleep.notes.isEmpty ? .gray : .secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
            
            if !sleep.dreams.isEmpty {
                Text("Dreams:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                
                // Show dream titles, limited to a few
                ForEach(sleep.dreams.prefix(3).indices, id: \.self) { index in
                    Text("• \(sleep.dreams[index].title)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                }
                if sleep.dreams.count > 3 {
                    Text("+\(sleep.dreams.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                }
            }
        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity) // Make the card take up the full width
    }
}

struct SleepCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSleep = Sleep(
            id: UUID(),
            dreams: [
                Dream(title: "Good Dream", description: "I had a very good dream.", tags: [], dreamType: .normal, isFavorite: true, rating: .neutral),
                Dream(title: "Weird Dream", description: "A very strange dream...", tags: [], dreamType: .normal, isFavorite: false, rating: .neutral),
                Dream(title: "Nightmare", description: "A terrible dream", tags: [], dreamType: .nightmare, isFavorite: false, rating: .neutral),
                Dream(title: "Another Dream", description: "Just another dream", tags: [], dreamType: .normal, isFavorite: false, rating: .neutral)
            ],
            date: Date(),
            notes: "Slept well, feeling rested.",
            timeZone: TimeZone.current
        )
        
        SleepCardView(sleep: .constant(sampleSleep))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
