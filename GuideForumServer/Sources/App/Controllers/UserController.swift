import Vapor
import Fluent

struct UserSignup: Content {
    
    let username: String
    let password: String
}

struct NewSession: Content {
    
    let token: String
    let user: User.Public
}

struct UpdateUser: Content {
    
    let username: String
    let avatar: String?
}

extension UserSignup: Validatable {
    
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        // http://localhost:8080/users
        let usersRoute = routes.grouped("users")
        
        // http://localhost:8080/users/signup
        usersRoute.post("signup", use: create)
        
        // Запросы защищены паролем, который был указан на этапе регистрации
        let passwordProtected = usersRoute.grouped(User.authenticator())
        
        // http://localhost:8080/users/login
        passwordProtected.post("login", use: login)
        
        // Запросы защищены токеном, который мы получаем на этапе авторизации / регистрации
        let tokenProtected = usersRoute.grouped(Token.authenticator())
        
        // http://localhost:8080/users/me
        tokenProtected.get("me", use: getMyOwnUser)
        
        // Запрос создания нового объекта dinner
        // http://localhost:8080/users/update
        tokenProtected.post("update") { req throws -> EventLoopFuture<User.Public> in
            let user = try req.auth.require(User.self)
            let updateData = try req.content.decode(UpdateUser.self)
            
            return User.query(on: req.db)
                .filter(\.$id == user.id!)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { existingUser in
                    user.username = updateData.username
                    if let newAvatar = updateData.avatar {
                        user.avatar = newAvatar
                    }
                    
                    return user.save(on: req.db)
                        .flatMapThrowing { _ in
                            try user.asPublic()
                        }
                }
        }
    }
    
    fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)
        var token: Token!
        
        return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: UserError.usernameTaken)
            }
            return user.save(on: req.db)
        }.flatMap {
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        
        return token.save(on: req.db).flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    func getMyOwnUser(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
    
    private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$username == username)
            .first()
            .map { $0 != nil }
    }
}
