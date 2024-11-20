import Foundation

struct Guide: Codable, Identifiable {
    
    let id: String
    let title: String
    let description: String
    let hashtags: [String]
    let image: String?
}
