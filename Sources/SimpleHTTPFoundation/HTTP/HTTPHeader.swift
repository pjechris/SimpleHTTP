import Foundation

/// HTTP headers `Dictionary` and their associated value
public typealias HTTPHeaderFields = [HTTPHeader: String]

/// A struct representing a http request header key
public struct HTTPHeader: Hashable, Sendable, ExpressibleByStringLiteral {
    public let key: String

    public init(stringLiteral value: StringLiteralType) {
        self.key = value
    }
}

extension HTTPHeader {
    public static let accept: Self = "Accept"
    public static let authentication: Self = "Authentication"
    public static let authorization: Self = "Authorization"
    public static let contentType: Self = "Content-Type"
    public static let contentDisposition: Self = "Content-Disposition"
}

// swiftlint:disable line_length
@available(*, unavailable, message: "This is a reserved header. See https://developer.apple.com/documentation/foundation/nsurlrequest#1776617")
// swiftlint:enable line_length
extension HTTPHeader {
    public static let connection: Self = "Connection"
    public static let contentLength: Self = "Content-Length"
    public static let host: Self = "Host"
    public static let proxyAuthenticate: Self = "Proxy-Authenticate"
    public static let proxyAuthorization: Self = "Proxy-Authorization"
    public static let wwwAuthenticate: Self = "WWW-Authenticate"
}

public extension HTTPHeaderFields {
    /// - Returns the content type if HTTPHeader.contentType was set
    var contentType: HTTPContentType? {
        self[.contentType].map(HTTPContentType.init(value:))
    }

    func contentType(_ value: HTTPContentType) -> Self {
        var copy = self

        copy[.contentType] = value.value

        return copy
    }
}
