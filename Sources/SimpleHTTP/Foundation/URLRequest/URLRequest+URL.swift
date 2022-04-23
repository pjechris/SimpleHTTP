import Foundation

extension URLRequest {
    /// Return a new URLRequest whose endpoint is relative to `baseURL`
    func relativeTo(_ baseURL: URL) -> URLRequest {
        var urlRequest = self
        var components = URLComponents(string: baseURL.appendingPathComponent(url?.path ?? "").absoluteString)
        
        components?.percentEncodedQuery = url?.query
        
        urlRequest.url = components?.url
                
        return urlRequest
    }
}
