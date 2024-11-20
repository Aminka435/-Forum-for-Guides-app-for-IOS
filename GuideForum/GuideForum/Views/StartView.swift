import SwiftUI

struct StartView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        if mainViewModel.isAuthorized || mainViewModel.isGuest {
            MainView()
        } else {
            AuthView()
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
