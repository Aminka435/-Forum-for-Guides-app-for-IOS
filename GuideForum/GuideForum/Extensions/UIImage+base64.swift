import UIKit

extension UIImage {
    
    var base64: String? {
        jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
