import Fluent
import Vapor

final class Guide: Model, Content {
    
    struct Public: Content {
        
        let id: UUID
        let title: String
        let description: String
        let hashtags: [String]
        let image: String?
        let host: User.Public
    }
    
    static let schema = "guides"
    
    @ID()
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "hashtags")
    var hashtags: [String]
    
    @Field(key: "image")
    var image: String?
    
    @Parent(key: "host_id")
    var host: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        title: String,
        description: String,
        hashtags: [String] = [],
        image: String? = nil,
        hostId: User.IDValue
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.hashtags = hashtags
        self.image = image
        self.$host.id = hostId
    }
}

extension Guide {
    
    func asPublic() throws -> Public {
        Public(
            id: try requireID(),
            title: title,
            description: description,
            hashtags: hashtags,
            image: image,
            host: try host.asPublic()
        )
    }
}
