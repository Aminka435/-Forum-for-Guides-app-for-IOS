import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: GuideController())
    app.routes.defaultMaxBodySize = "10mb"
}
