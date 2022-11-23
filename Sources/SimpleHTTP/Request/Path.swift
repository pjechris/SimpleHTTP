import Foundation

/// A path represents a path a request can query to
///
/// You can create paths using plain String, for instance:
/// ```swift
/// extension Path {
///   static let user = "v1/users"
/// }
///
/// If you want to regroup a set of paths you can use your own "namespace" and add a forward declaration in `Path`.
/// Adding a declaration provide autocompletion when using it in `Request`.
/// ```swift
/// enum MyPaths {
///   static let user: Path = "v1/users"
/// }
///
/// extension Path {
///   static let myPaths = MyPaths.self
/// }
///
/// let user: Path = .myPaths.user
/// ```
public struct Path: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// relative path
    public let value: String

    init(value: String) {
        self.value = value
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value: value)
    }

    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(value: stringInterpolation.description)
    }

    public static func ==(lhs: Path, rhs: String) -> Bool {
        lhs.value == rhs
    }
}
