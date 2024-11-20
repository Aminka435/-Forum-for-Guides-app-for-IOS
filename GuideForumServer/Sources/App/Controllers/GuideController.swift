import Vapor
import Fluent

struct NewGuide: Content {
    
    let title: String
    let description: String
    let hashtags: [String]
    let image: String?
}

struct GuideController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        // http://localhost:8080/guides
        let guidesRoute = routes.grouped("guides")
        
        let tokenProtected = guidesRoute.grouped(Token.authenticator())
        
        // http://localhost:8080/guides/new
        tokenProtected.post("new") { req throws -> EventLoopFuture<Bool> in
            let user = try req.auth.require(User.self)
            
            let newGuide = try req.content.decode(NewGuide.self)
            let guide = Guide(
                title: newGuide.title,
                description: newGuide.description,
                hashtags: newGuide.hashtags,
                image: newGuide.image,
                hostId: try user.requireID()
            )
            
            // Сохраняем в базе данных
            return guide.save(on: req.db)
                .flatMapThrowing { _ in
                    return true
                }
        }
        
        // http://localhost:8080/guides/all
        tokenProtected.get("all") { req throws -> EventLoopFuture<[Guide.Public]> in
            return Guide.query(on: req.db)
                .with(\.$host)
                .all()
                .flatMapThrowing { guides in try guides.map { try $0.asPublic() } }
        }
        
        // http://localhost:8080/guides/all
        tokenProtected.get("my") { req throws -> EventLoopFuture<[Guide.Public]> in
            let user = try req.auth.require(User.self)
            
            return Guide.query(on: req.db)
                .with(\.$host)
                .filter(\.$host.$id == user.id!)
                .all()
                .flatMapThrowing { guides in try guides.map { try $0.asPublic() } }
        }
    }
    
    fileprivate func getGuide(req: Request) throws -> EventLoopFuture<Guide.Public> {
        guard let guideId = req.parameters.get("guideId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Guide.query(on: req.db)
            .filter(\.$id == guideId)
            .with(\.$host)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { try $0.asPublic() }
    }
}
