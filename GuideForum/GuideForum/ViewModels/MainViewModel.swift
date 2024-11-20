import SwiftUI

class MainViewModel: ObservableObject {
    
    private let favouriteGuidesKey: String = "favourite_guides"
    
    @Published var username: String = ""
    @Published var isAuthorized = false
    @Published var isGuest: Bool = false { didSet { CredentialsStore.isGuest = isGuest } }
    
    @Published var user: User? {
        didSet {
            isAuthorized = user != nil
            CredentialsStore.user = user
            username = user?.username ?? ""
        }
    }
    
    @Published var guides: [Guide] = []
    
    init() {
        isAuthorized = CredentialsStore.authToken != nil
        isGuest = CredentialsStore.isGuest
        user = CredentialsStore.user
    }
    
    func like(guideId: String) -> Bool {
        var favouriteGuidesIds = UserDefaults.standard.array(forKey: favouriteGuidesKey) as? [String] ?? []
        var isLiked = false
        if let index = favouriteGuidesIds.firstIndex(where: { $0 == guideId }) {
            favouriteGuidesIds.remove(at: index)
        } else {
            favouriteGuidesIds.append(guideId)
            isLiked = true
        }
        UserDefaults.standard.set(favouriteGuidesIds, forKey: favouriteGuidesKey)
        return isLiked
    }
    
    func isLiked(guideId: String) -> Bool {
        let favouriteGuidesIds = UserDefaults.standard.array(forKey: favouriteGuidesKey) as? [String] ?? []
        return favouriteGuidesIds.contains(guideId)
    }
    
    func clearLiked() {
        UserDefaults.standard.removeObject(forKey: favouriteGuidesKey)
    }
    
    func logout() {
        CredentialsStore.clean()
        username = ""
        isAuthorized = false
        isGuest = false
        user = nil
        clearLiked()
    }
}
