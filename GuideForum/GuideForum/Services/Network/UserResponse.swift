import Foundation

struct UserResponse: Codable, Hashable {
    
    let token: String
    let user: User
}
