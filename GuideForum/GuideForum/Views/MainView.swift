import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "star")
                }
            if mainViewModel.isGuest == false {
                MyGuidesView()
                    .tabItem {
                        Label("My Guides", systemImage: "book")
                    }
            }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(Color.blue.opacity(0.8))
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView()
    }
}
