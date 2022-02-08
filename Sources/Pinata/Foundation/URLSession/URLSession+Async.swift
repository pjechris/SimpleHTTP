import Foundation

extension URLSession {
    public func dataTask(with urlRequest: URLRequest) async throws -> (data: Data, response: URLResponse) {
        try await withCheckedThrowingContinuation { promise in
            self.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let response = response else {
                    return promise.resume(throwing: error ?? URLError(.badServerResponse))
                }

                promise.resume(returning: (data, response))
            }
            .resume()
        }
    }
}
