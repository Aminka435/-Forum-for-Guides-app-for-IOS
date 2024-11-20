import SwiftUI

struct FavouritesView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @State private var path: [String] = []
    @State private var guides: [Guide] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(guides) { guide in
                    GuideItemView(path: $path, guide: guide)
                }
            }
            .navigationDestination(for: String.self) { guideId in
                if let guide = guides.first(where: { $0.id == guideId }) {
                    GuideView(path: $path, guide: guide)
                }
            }
            .navigationTitle("Favourites")
            .onAppear {
                getFavouriteGuides()
            }
        }
    }
    
    private func getFavouriteGuides() {
        NetworkService.getAllGuides { guides in
            DispatchQueue.main.async {
                self.guides = guides.filter { mainViewModel.isLiked(guideId: $0.id) }
            }
        }
    }
}

struct Favourites_Previews: PreviewProvider {
    
    static var previews: some View {
        FavouritesView()
    }
}
