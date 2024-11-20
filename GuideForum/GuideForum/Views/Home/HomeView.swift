import SwiftUI

struct HomeView: View {
    
    @State private var path: [String] = []
    @State private var allGuides: [Guide] = []
    @State private var searchString = ""
    
    private var filteredGuides: [Guide] {
        if searchString.isEmpty {
            return allGuides
        } else {
            return allGuides
                .filter {
                    $0.hashtags
                        .map { $0.lowercased().contains(searchString.lowercased()) }
                        .contains(true)
                }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(filteredGuides) { guide in
                    GuideItemView(path: $path, guide: guide)
                }
            }
            .navigationDestination(for: String.self) { guideId in
                if let guide = allGuides.first(where: { $0.id == guideId }) {
                    GuideView(path: $path, guide: guide)
                }
            }
            .navigationTitle("Home")
            .onAppear {
                getAllGuides()
            }
        }
        .searchable(text: $searchString)
    }
    
    private func getAllGuides() {
        NetworkService.getAllGuides { guides in
            DispatchQueue.main.async {
                self.allGuides = guides
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
    }
}
