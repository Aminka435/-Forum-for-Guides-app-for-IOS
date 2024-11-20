import SwiftUI

struct MyGuidesView: View {
    
    @State private var path: [String] = []
    
    @State var guides: [Guide] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                AddGuideItemView(path: $path)
                ForEach(guides) { guide in
                    GuideItemView(path: $path, guide: guide)
                }
            }
            .navigationDestination(for: String.self) { guideId in
                if let guide = guides.first(where: { $0.id == guideId }) {
                    GuideView(path: $path, guide: guide)
                } else {
                    AddGuideView(path: $path)
                }
            }
            .navigationTitle("My guides")
            .onAppear {
                getMyGuides()
            }
        }
    }
    
    private func getMyGuides() {
        NetworkService.getMyGuides { guides in
            DispatchQueue.main.async {
                self.guides = guides
            }
        }
    }
}

struct MyGuidesView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyGuidesView()
    }
}

