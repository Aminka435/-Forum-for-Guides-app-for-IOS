import Foundation

struct User: Codable, Hashable {
    
    let id: String
    var username: String
    var avatar: String?
}
