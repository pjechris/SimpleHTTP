import Foundation

/// A endpoint represents a path a request can query to
///
/// You can create endpoints using plain String, for instance:
/// ```swift
/// extension Endpoint {
///   static let user = "v1/users"
/// }
///
/// If you want to regroup a set of endpoints you can use your own "namespace" and add a forward declaration in `Endpoint`.
/// Adding a declaration provide autocompletion when using it in `Request`.
/// ```swift
/// enum MyEndpoints {
///   static let user: Endpoint = "v1/users"
/// }
///
/// extension Endpoint {
///   static let myEndpoints = MyEndpoints.self
/// }
///
/// let user: Endpoint = .myEndpoints.user
/// ```
public struct Endpoint: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// relative path
    public let path: String

    init(path: String) {
        self.path = path
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(path: value)
    }
    
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(path: stringInterpolation.description)
    }
}

