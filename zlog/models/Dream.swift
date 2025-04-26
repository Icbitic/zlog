import Foundation

struct Dream: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var tags: [Tag]
    var dreamType: DreamType
    var isFavorite: Bool
    var images: Data?
    var rating: DreamRating
    var isUploaded: Bool
    
    init(id: UUID = UUID(), title: String, description: String, tags: [Tag], dreamType: DreamType, isFavorite: Bool, images: Data? = nil, rating: DreamRating, isUploaded: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.tags = tags
        self.dreamType = dreamType
        self.isFavorite = isFavorite
        self.images = images
        self.rating = rating
        self.isUploaded = isUploaded
    }
}

enum DreamType: String, Codable, CaseIterable {
    case lucid, nightmare, normal, fragment
}

enum DreamRating: Int, Codable, CaseIterable, Identifiable {
    case awful = 1
    case bad
    case neutral
    case good
    case amazing
    
    var id: Int { rawValue }
    
    var label: String {
        switch self {
        case .awful: return "Awful"
        case .bad: return "Bad"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .amazing: return "Amazing"
        }
    }
}

extension Dream {
    static let sampleDreams: [Dream] = [
        Dream(title: "man on fire",
              description: "see a person on fire",
              tags: [.fire],
              dreamType: .nightmare,
              isFavorite: false,
              rating: .bad),
        Dream(title: "goin' out with friends",
              description: "driving a caravan on the expressway, stopped by the po, tired",
              tags: [.ocean],
              dreamType: .normal,
              isFavorite: true,
              rating: .good),
        Dream(title: "ghost encounter",
              description: "the elavator stopped anomally, when i tried to rerun the elavator, something went out... ",
              tags: [.elevator],
              dreamType: .nightmare,
              isFavorite: false,
              rating: .awful)
    ]
}

extension Dream {
    enum CodingKeys: String, CodingKey {
        case id, title, description, tags, dreamType, isFavorite, images, rating, isUploaded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Basic properties, these should not fail.
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.tags = try container.decode([Tag].self, forKey: .tags)
        self.dreamType = try container.decode(DreamType.self, forKey: .dreamType)
        self.images = try? container.decode(Data.self, forKey: .images) //handle error
        
        // Decoding for isFavorite with default value
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
        
        self.images = try? container.decode(Data.self, forKey: .images)

        // Decoding for isUploaded with default value
        let isUploadedValue = try? container.decode(Bool.self, forKey: .isUploaded)
        let isUploadedString = try? container.decode(String.self, forKey: .isUploaded)
        let isUploadedInt = try? container.decode(Int.self, forKey: .isUploaded)
        
        if let value = isUploadedValue {
            self.isUploaded = value
        } else if let stringValue = isUploadedString {
            self.isUploaded = stringValue.lowercased() == "true"
        } else if let intValue = isUploadedInt {
            self.isUploaded = intValue == 1
        } else {
            self.isUploaded = false
        }
        
        // Decoding for rating with default value
        if let ratingInt = try? container.decode(Int.self, forKey: .rating) {
            self.rating = DreamRating(rawValue: ratingInt) ?? .neutral
        } else if let ratingString = try? container.decode(String.self, forKey: .rating) {
            switch ratingString.lowercased() {
            case "awful": self.rating = .awful
            case "bad": self.rating = .bad
            case "neutral": self.rating = .neutral
            case "good": self.rating = .good
            case "amazing": self.rating = .amazing
            default: self.rating = .neutral
            }
        } else {
            self.rating = .neutral
        }
    }
}

