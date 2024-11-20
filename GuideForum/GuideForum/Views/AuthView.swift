import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                authButton(destination: LoginView(), name: "Log in")
                authButton(destination: SigninView(), name: "Sign in")
                
                Button(action: {
                    mainViewModel.isGuest = true
                }, label: {
                    Text("Log in as guest")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 40)
                        .background(.blue)
                        .cornerRadius(10)
                })
            }
        }
    }
    
    private func authButton<D: View>(destination: D, name: String) -> some View {
        HStack {
            NavigationLink(destination: destination) {
                Text(name)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 40)
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
