import SwiftUI

@main
struct GuideForumApp: App {
    
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(mainViewModel)
        }
    }
}


