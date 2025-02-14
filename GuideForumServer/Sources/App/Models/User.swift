import Fluent
import Vapor

final class User: Model {
    
    struct Public: Content {
        
        let id: UUID
        let username: String
        let avatar: String?
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    static let schema = "users"
    
    @ID()
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "avatar")
    var avatar: String?
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, username: String, avatar: String? = nil, passwordHash: String) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.passwordHash = passwordHash
    }
}

extension User {
    
    static func create(from userSignup: UserSignup) throws -> User {
        User(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password))
    }
    
    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(
            userId: requireID(),
            token: [UInt8].random(count: 16).base64,
            source: source,
            expiresAt: expiryDate
        )
    }
    
    func asPublic() throws -> Public {
        Public(
            id: try requireID(),
            username: username,
            avatar: avatar,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension User: ModelAuthenticatable {
    
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
