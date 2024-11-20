import Foundation

extension FileManager {
    
    static var documentDirectory: URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    
    static func getUrl(to pathComponent: String) -> URL {
        return documentDirectory.appendingPathComponent(pathComponent)
    }
    
    static func fetch<T: Codable>(filename: String) -> T? {
        let fileUrl = FileManager.getUrl(to: filename)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                let data = try Data(contentsOf: fileUrl)
                return try PropertyListDecoder().decode(T.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    static func save<T: Codable>(object: T, filename: String) {
        let fileUrl = FileManager.getUrl(to: filename)
        
        guard let data = try? PropertyListEncoder().encode(object) else { return }
        do {
            try data.write(to: fileUrl, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func removeItem(filename: String) {
        let fileUrl = FileManager.getUrl(to: filename)
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) == true else { return }
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
}
