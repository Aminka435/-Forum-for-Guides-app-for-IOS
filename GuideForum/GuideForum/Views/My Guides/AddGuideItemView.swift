import SwiftUI

struct AddGuideItemView: View {
    
    @Binding var path: [String]
    
    var body: some View {
        HStack {
            Text("New guide")
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 18))
                .foregroundColor(.red)
        }
        .contentShape(Rectangle())
        .frame(height: 40)
        .onTapGesture {
            path.append("Add Guide")
        }
    }
}
