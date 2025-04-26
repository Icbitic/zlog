import Foundation

struct Sleep: Identifiable, Codable, Equatable {
    var id: UUID
    var dreams: [Dream]
    var date: Date
    var notes: String
    var timeZone: TimeZone
    
    var abbreviatedDescription: String {
        // Use a fixed calendar and time zone to avoid automatic adjustment
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        let components = calendar.dateComponents([.hour, .weekday, .day, .month], from: date)
        
        // Determine part of the day
        let hour = components.hour ?? 0
        let partOfDay: String
        if hour < 11 {
            partOfDay = "Morning"
        } else if hour >= 17 {
            partOfDay = "Night"
        } else {
            partOfDay = "Noon"
        }
        
        // Format weekday and month using DateFormatter
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Keep it consistent
        formatter.dateFormat = "E, MMM d"
        
        let dateString = formatter.string(from: date)
        
        return "\(dateString) \(partOfDay)"
    }
    
    var detailedDescription: String {
        let calendar = Calendar(identifier: .gregorian)
        let gmtTimeZone = TimeZone(secondsFromGMT: 0)!
        
        var calendarWithGMT = calendar
        calendarWithGMT.timeZone = gmtTimeZone
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = gmtTimeZone
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        
        let dateString = formatter.string(from: date)
        
        return "\(dateString)"
    }
    
    init(id: UUID = UUID(), dreams: [Dream] = [], date: Date = Date.now, notes: String = "", timeZone: TimeZone = .current) {
        self.id = id
        self.dreams = dreams
        self.date = date
        self.notes = notes
        self.timeZone = timeZone
    }
}

extension Date {
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }
    
    static var theDayBeforeYesterday: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: .now)!
    }
    
    static var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: .now)!
    }
}


extension Sleep {
    static let sampleSleep = [
        Sleep(dreams: [Dream.sampleDreams[0], Dream.sampleDreams[1]],
              date: .now,
              notes: "the firing dream is too scary"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[1]],
              date: .theDayBeforeYesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[0]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
        Sleep(dreams: [Dream.sampleDreams[2]],
              date: .yesterday,
              notes: "omg"),
    ]
}
