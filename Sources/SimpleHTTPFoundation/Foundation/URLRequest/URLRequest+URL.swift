import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    /// Return a new URLRequest whose path is relative to `baseURL`
    public func relativeTo(_ baseURL: URL) -> URLRequest {
        var urlRequest = self
        var components = URLComponents(string: baseURL.appendingPathComponent(url?.path ?? "").absoluteString)

        components?.percentEncodedQuery = url?.query

        urlRequest.url = components?.url

        return urlRequest
    }
}
