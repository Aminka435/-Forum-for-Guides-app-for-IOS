import UIKit
import SwiftUI
import PhotosUI

struct AddGuideView: View {
    
    @Binding var path: [String]
    
    @State private var title = ""
    @State private var description = ""
    @State private var hashtags = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Title", text: $title)
                    .frame(height: 40)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            HStack {
                TextField("Description", text: $description)
                    .frame(height: 40)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            HStack {
                TextField("Hashtags", text: $hashtags)
                    .frame(height: 40)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            PhotosPicker(selection: $avatarItem, matching: .images) {
                if let image = avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                }
            }
            Button {
                addGuide()
            } label: {
                Text("Add Guide")
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 40)
            .background(.blue)
            .cornerRadius(10)

            Spacer()
        }
        .navigationTitle("New Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: avatarItem) { _ in
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        avatarImage = uiImage
                        return
                    }
                }
            }
        }
    }
    
    private func addGuide() {
        var compressedImage: UIImage? = nil
        if
            let avatarImage = avatarImage,
            let data = avatarImage.jpegData(compressionQuality: 0)
        {
            compressedImage = UIImage(data: data)
        }
        NetworkService.newGuide(
            guide: Guide(
                id: UUID().uuidString,
                title: title,
                description: description,
                hashtags: hashtags
                    .components(separatedBy: CharacterSet(charactersIn: ", "))
                    .filter { $0.isEmpty == false }
                    .map { $0.lowercased() },
                image: compressedImage?.base64
            ),
            completion: { added in
                DispatchQueue.main.async {
                    self.path = []
                }
            }
        )
    }
}
