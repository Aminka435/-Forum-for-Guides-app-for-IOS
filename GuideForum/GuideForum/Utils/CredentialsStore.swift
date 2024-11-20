import Foundation

class CredentialsStore {
    
    private static let authTokenKey = "auth_token"
    private static let userKey = "user"
    private static let isGuestKey = "is_guest"
    
    static var authToken: String? {
        get { UserDefaults.standard.string(forKey: authTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: authTokenKey) }
    }
    
    static var user: User? {
        get { FileManager.fetch(filename: userKey) }
        set { FileManager.save(object: newValue, filename: userKey) }
    }
    
    static var isGuest: Bool {
        get { UserDefaults.standard.bool(forKey: isGuestKey) }
        set { UserDefaults.standard.set(newValue, forKey: isGuestKey) }
    }
    
    static func clean() {
        UserDefaults.standard.removeObject(forKey: authTokenKey)
        FileManager.removeItem(filename: userKey)
    }
}
