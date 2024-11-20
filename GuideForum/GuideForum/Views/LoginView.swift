import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @State private var textLogin = ""
    @State private var textPassword = ""
    @State private var isShowAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            loginField(title: "Login", value: $textLogin)
            loginField(title: "Password", value: $textPassword)
            
            loginButton()
        }
        .navigationTitle("Log in")
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("Authorisation Error"),
                message: Text("Check the entered data"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func loginField(
        title: String,
        value: Binding<String>
    ) -> some View {
        HStack {
            TextField(title, text: value)
                .frame(width: 270, height: 40)
                .padding(.horizontal, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.gray, lineWidth: 1)
        )
    }
    
    private func loginButton() -> some View {
        Button(action: {
            loginUser()
        }, label: {
            Text("Log in")
                .foregroundColor(.black)
                .frame(width: 294, height: 40)
                .background(.white)
                .cornerRadius(10)
        })
    }
    
    private func loginUser() {
        NetworkService.login(
            username: textLogin,
            password: textPassword,
            completion: { user in
                DispatchQueue.main.async {
                    self.mainViewModel.user = user
                }
            },
            failed: { error in
                DispatchQueue.main.async {
                    self.isShowAlert = true
                }
            }
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
