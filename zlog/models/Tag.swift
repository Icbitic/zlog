import Foundation
import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var tagName: String
    var details: String
    
    /// color stored in hex format
    var color: String
    
    init(id: UUID = UUID(), tagName: String, details: String, color: String) {
        self.id = id
        self.tagName = tagName
        self.details = details
        self.color = color
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 8:
            r = Double((int >> 24) & 0xFF) / 255.0
            g = Double((int >> 16) & 0xFF) / 255.0
            b = Double((int >> 8)  & 0xFF) / 255.0
            a = Double((int >> 0)  & 0xFF) / 255.0
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8)  & 0xFF) / 255.0
            b = Double((int >> 0)  & 0xFF) / 255.0
            a = 1.0
        default:
            r = 0; g = 0; b = 0; a = 1.0
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

}

extension Color {
    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgba = (
            Int(r * 255) << 24 |
            Int(g * 255) << 16 |
            Int(b * 255) << 8  |
            Int(a * 255)
        )
        return String(format: "%08x", rgba)
    }
}


extension Tag {
    static let fire = Tag(tagName: "fire", details: "dreaming about fire", color: Color.red.toHex())
    static let ocean = Tag(tagName: "ocean", details: "dreaming about oceans", color: Color.blue.toHex())
    static let caravan = Tag(tagName: "caravan", details: "go camping!", color: Color.green.toHex())
    static let elevator = Tag(tagName: "elevator", details: "something in the lifter", color: Color.gray.toHex())
    
    static let sampleTags: [Tag] = [
        .fire, .caravan, .ocean
    ]
}
