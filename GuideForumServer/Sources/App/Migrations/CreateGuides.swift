import Fluent

struct CreateGuides: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Guide.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("hashtags", .array(of: .string), .required)
            .field("image", .string)
            .field("host_id", .uuid, .references("users", "id"), .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Guide.schema).delete()
    }
}
