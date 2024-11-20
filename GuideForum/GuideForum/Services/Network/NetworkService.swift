import Foundation

struct NetworkService {
    
    private static let baseUrlString = "http://localhost:8080/"
    private static let signinPath = "users/signup"
    private static let loginPath = "users/login"
    private static let updatePath = "users/update"
    private static let mePath = "users/me"
    private static let allGuidesPath = "guides/all"
    private static let myGuidesPath = "guides/my"
    private static let newGuidePath = "guides/new"
    private static let urlSession = URLSession(configuration: .default)
    
    static func signIn(
        username: String,
        password: String,
        completion: ((User) -> Void)? = nil,
        failed: ((Error) -> Void)? = nil
    ) {
        guard let request = signInRequest(username: username, password: password) else {
            print("Bad request")
            return
        }
        auth(request: request, completion: completion, failed: failed)
    }
    
    static func login(
        username: String,
        password: String,
        completion: ((User) -> Void)? = nil,
        failed: ((Error) -> Void)? = nil
    ) {
        guard let request = loginRequest(username: username, password: password) else {
            print("Bad request")
            return
        }
        auth(request: request, completion: completion, failed: failed)
    }
    
    static func updateUser(user: User, completion: @escaping (User) -> Void) {
        guard let request = updateUserRequest(username: user.username, avatar: user.avatar) else {
            print("Bad request")
            return
        }
        return urlSession.request(urlRequest: request) { (result: Result<User, Error>) in
            
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func getUser(completion: @escaping (User) -> Void) {
        guard let request = getUserRequest() else {
            print("Bad request")
            return
        }
        return urlSession.request(urlRequest: request) { (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func getAllGuides(completion: @escaping ([Guide]) -> Void) {
        guard let request = getAllGuidesRequest() else {
            print("Bad request")
            return
        }
        return urlSession.request(urlRequest: request) { (result: Result<[Guide], Error>) in
            switch result {
            case .success(let guides):
                completion(guides)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func getMyGuides(completion: @escaping ([Guide]) -> Void) {
        guard let request = getMyGuidesRequest() else {
            print("Bad request")
            return
        }
        return urlSession.request(urlRequest: request) { (result: Result<[Guide], Error>) in
            switch result {
            case .success(let guides):
                completion(guides)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func newGuide(guide: Guide, completion: @escaping (Bool) -> Void) {
        guard let request = newGuideRequest(guide: guide) else {
            print("Bad request")
            return
        }
        return urlSession.request(urlRequest: request) { (result: Result<Bool, Error>) in
            switch result {
            case .success(let created):
                completion(created)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private static func auth(request: URLRequest, completion: ((User) -> Void)? = nil, failed: ((Error) -> Void)? = nil) {
        return urlSession.request(urlRequest: request) { (result: Result<UserResponse, Error>) in
            switch result {
            case .success(let userResponse):
                CredentialsStore.authToken = userResponse.token
                CredentialsStore.user = userResponse.user
                completion?(userResponse.user)
            case .failure(let error):
                print(error.localizedDescription)
                failed?(error)
            }
        }
    }
    
    private static func signInRequest(username: String, password: String) -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(signinPath)")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let json: [String: Any] = ["username": username, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        urlRequest.httpBody = jsonData
        return urlRequest
    }
    
    private static func loginRequest(username: String, password: String) -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(loginPath)")!)
        urlRequest.httpMethod = "POST"
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private static func updateUserRequest(username: String, avatar: String?) -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(updatePath)")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(CredentialsStore.authToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var json: [String: Any] = ["username": username]
        if let avatar = avatar {
            json["avatar"] = avatar
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        urlRequest.httpBody = jsonData
        return urlRequest
    }
    
    private static func getUserRequest() -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(mePath)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(CredentialsStore.authToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private static func getAllGuidesRequest() -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(allGuidesPath)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(CredentialsStore.authToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private static func getMyGuidesRequest() -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(myGuidesPath)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(CredentialsStore.authToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private static func newGuideRequest(guide: Guide) -> URLRequest? {
        var urlRequest = URLRequest(url: URL(string: "\(baseUrlString)\(newGuidePath)")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(CredentialsStore.authToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var json: [String: Any] = ["title": guide.title, "description": guide.description, "hashtags": guide.hashtags]
        if let image = guide.image {
            json["image"] = image
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        urlRequest.httpBody = jsonData
        return urlRequest
    }
}
