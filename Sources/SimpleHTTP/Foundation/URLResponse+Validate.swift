import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLResponse {
    /// Validate when self is of type `HTTPURLResponse`
    public func validate() throws {
        if let response = self as? HTTPURLResponse {
            try response.validateStatusCode()
        }
    }
}

extension HTTPURLResponse {
    /// Throw an error when response status code is not Success (2xx)
    func validateStatusCode() throws {
        guard (200..<300).contains(statusCode) else {
            throw HTTPError(statusCode: statusCode)
        }
    }
}
