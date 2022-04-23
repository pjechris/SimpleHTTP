import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {
    /// check whether a response is valid or not
    public func validate() throws {
        guard (200..<300).contains(statusCode) else {
            throw HTTPError(statusCode: statusCode)
        }
    }
}
