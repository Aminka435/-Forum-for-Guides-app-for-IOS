//
//  ProfileView.swift
//  GuideForum
//
//  Created by Kamila Alieva on 30.03.2023.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @State private var path: [String] = []
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    @State private var avatarItem: PhotosPickerItem?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Spacer()
                    if mainViewModel.isGuest {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    } else {
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            if let uiImage = mainViewModel.user?.avatar?.imageFromBase64 {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    if mainViewModel.isGuest {
                        Text("Guest")
                            .frame(height: 40)
                    } else {
                        TextField("Username", text: $mainViewModel.username)
                            .focused($isFocused)
                            .allowsHitTesting(isFocused)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(isFocused ? Color.gray : .clear, lineWidth: 1)
                            )
                        Button(action: {
                            if isFocused {
                                updateUser()
                            }
                            isFocused.toggle()
                        }) {
                            Text(isFocused ? "Done" : "Edit")
                        }
                        
                        if isFocused {
                            Button(action: {
                                isFocused.toggle()
                                mainViewModel.username = mainViewModel.user?.username ?? ""
                            }) {
                                Text("Cancel")
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
                Button(action: {
                    logout()
                }) {
                    Text(mainViewModel.isGuest ? "Authorize" : "Logout")
                        .foregroundColor(.white)
                }
                .frame(width: 200, height: 40)
                .background(.blue)
                .cornerRadius(10)
                .padding(.bottom, 60)
            }
            .padding()
            .onChange(of: avatarItem) { _ in
                Task {
                    if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                        if
                            let uiImage = UIImage(data: data),
                            let compressedData = uiImage.jpegData(compressionQuality: 0),
                            let compressedImage = UIImage(data: compressedData)
                        {
                            mainViewModel.user?.avatar = compressedImage.base64
                            updateUser()
                            return
                        }
                    }
                }
            }
            .onAppear {
                NetworkService.getUser { user in
                    DispatchQueue.main.async {
                        self.mainViewModel.user = user
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private func updateUser() {
        mainViewModel.user?.username = mainViewModel.username
        if let user = mainViewModel.user {
            NetworkService.updateUser(user: user, completion: { user in
                DispatchQueue.main.async {
                    self.mainViewModel.user = user
                }
            })
        }
    }
    
    private func logout() {
        mainViewModel.logout()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
