import Foundation

extension URLSession {
    @available(iOS, deprecated: 15.0, message: "Use built-in API instead")
    public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { promise in
            self.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    promise.resume(throwing: error)
                }
                
                guard let data = data, let response = response else {
                    return promise.resume(throwing: URLError(.badServerResponse))
                }
                
                promise.resume(returning: (data, response))
            }
            .resume()
        }
    }
    
    public func data(for urlRequest: URLRequest) async throws -> URLDataResponse {
        let (data, response) = try await data(for: urlRequest)
        
        return URLDataResponse(data: data, response: response as! HTTPURLResponse)
    }
}
