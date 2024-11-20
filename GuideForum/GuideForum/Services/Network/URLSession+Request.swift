import Foundation

extension URLSession {
    
    private static let acceptableStatusCodes: Range<Int> = 200..<300
    
    public func request<T: Decodable>(
        urlRequest: URLRequest,
        decoder: JSONDecoder = .init(),
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let data = data, let response = response else {
                return completion(
                    .failure(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No data")))
                )
            }
            
            do {
                let data = try self.handleResponse(data: data, response: response)
                let model: T = try JSONDecoder().decode(T.self, from: data)
                return completion(.success(model))
            } catch {
                return completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func handleResponse(data: Data, response: URLResponse) throws -> Data {
        if let httpResponse = response as? HTTPURLResponse {
            if URLSession.acceptableStatusCodes ~= httpResponse.statusCode {
                return data
            } else {
                throw URLError(.badServerResponse)
            }
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid response"))
        }
    }
}
