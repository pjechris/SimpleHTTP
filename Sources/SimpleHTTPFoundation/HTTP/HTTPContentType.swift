import Foundation

/// A struct representing a http header content type value
public struct HTTPContentType: Hashable, ExpressibleByStringLiteral {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

extension HTTPContentType {
    public static let json: Self = "application/json"
    public static let octetStream: Self = "application/octet-stream"
    public static func multipart(boundary: String) -> Self {
        .init(value: "multipart/form-data; boundary=\(boundary)")
    }
}
