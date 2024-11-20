import SwiftUI

struct SigninView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @State private var textNickname = ""
    @State private var textLogin = ""
    @State private var textPassword = ""
    @State private var textConfirmPassword = ""
    @State private var isShowAlert: Bool = false
    
    private var isDisabled: Bool {
        textNickname.count == 0 || textPassword.count < 6 || textPassword != textConfirmPassword
    }
    
    var body: some View {
        VStack(spacing: 20) {
            signinField(title: "Nickname", value: $textNickname)
            signinField(title: "Password", value: $textPassword)
            signinField(title: "Confirm password", value: $textConfirmPassword)
            
            signinButton()
        }
        .navigationTitle("Sign in")
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("Registration error"),
                message: Text("This nickname is already taken"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    
    private func signinField(
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
    
    private func signinButton() -> some View {
        Button(action: {
            registerUser()
        }, label: {
            Text("Sign in")
                .foregroundColor(isDisabled ? .secondary : .white)
                .frame(width: 294, height: 40)
                .background(isDisabled ? Color.gray.opacity(0.3) : .blue)
                .cornerRadius(10)
        })
        .disabled(isDisabled)
    }
    
    private func registerUser() {
        NetworkService.signIn(
            username: textNickname,
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

struct SigninView_Previews: PreviewProvider {
    
    static var previews: some View {
        SigninView()
    }
}
