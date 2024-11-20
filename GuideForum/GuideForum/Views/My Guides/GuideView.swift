import SwiftUI

struct GuideView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @State private var isLiked: Bool = false
    
    @Binding var path: [String]
    let guide: Guide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                if let uiImage = guide.image?.imageFromBase64 {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .cornerRadius(20)
                }
                Spacer()
            }
            
            Text(guide.description)
                .foregroundColor(.black)
                .font(.system(size: 16))
                .padding(.bottom, 20)
            Text(guide.hashtags.map { "#" + $0 }.joined(separator: ", "))
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Spacer()
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: {
                likeTapped()
            }, label: {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundColor(isLiked ? Color.red : Color.blue)
            })
        )
        .padding()
        .onAppear {
            isLiked = mainViewModel.isLiked(guideId: guide.id)
        }
    }
    
    private func likeTapped() {
        isLiked = mainViewModel.like(guideId: guide.id)
    }
}
