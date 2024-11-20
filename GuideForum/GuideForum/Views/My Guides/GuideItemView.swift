import SwiftUI

struct GuideItemView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @State private var isLiked: Bool = false
    
    @Binding var path: [String]
    let guide: Guide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(guide.title)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    Text(guide.description)
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                    Text(guide.hashtags.map { "#" + $0 }.joined(separator: ", "))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                }
                Spacer()
                if let image = guide.image?.imageFromBase64 {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                path.append(guide.id)
            }
            .onAppear {
                isLiked = mainViewModel.isLiked(guideId: guide.id)
            }
            
            Button(action: {
                likeTapped()
            }, label: {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundColor(isLiked ? Color.red : Color.blue)
            })
            .frame(width: 24, height: 24)
        }
    }
    
    private func likeTapped() {
        isLiked = mainViewModel.like(guideId: guide.id)
    }
}
