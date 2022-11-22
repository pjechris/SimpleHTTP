import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    /// Set the headers on the request
    public mutating func setHeaders(_ headers: HTTPHeaderFields) {
        for (header, value) in headers {
            setValue(value, forHTTPHeaderField: header.key)
        }
    }

    /// Return a new `URLRequest`` with added `headers``
    public func settingHeaders(_ headers: HTTPHeaderFields) -> Self {
        var urlRequest = self

        urlRequest.setHeaders(headers)

        return urlRequest
    }
}
