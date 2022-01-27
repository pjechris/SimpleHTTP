import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    public mutating func setHeaders(_ headers: HTTPHeaderFields) {
        for (header, value) in headers {
            setValue(value, forHTTPHeaderField: header.key)
        }
    }
}
