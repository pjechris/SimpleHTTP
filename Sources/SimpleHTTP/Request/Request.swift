import Foundation

public enum Method: String {
    case get
    case post
    case put
    case patch
    case delete
}

public enum Body {
    case encodable(Encodable)
    case multipart(MultipartFormData)
}

/// A HTTP request safely typed for an `Output` response
///
/// Highly inspired by https://swiftwithmajid.com/2021/02/10/building-type-safe-networking-in-swift/
public struct Request<Output> {
    /// request relative path
    public let path: Path
    public let method: Method
    public let body: Body?
    public let query: [String: QueryParam]
    public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    public var headers: HTTPHeaderFields = [:]

    /// Creates a request suitable for a HTTP GET
    public static func get(_ path: Path, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .get, query: query, body: nil)
    }

    /// Creates a request suitable for a HTTP POST with a `Encodable` body
    public static func post(_ path: Path, body: Encodable?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .post, query: query, body: body.map(Body.encodable))
    }

    /// Creates a request suitable for a HTTP POST with a `MultipartFormData` body
    @_disfavoredOverload
    public static func post(_ path: Path, body: MultipartFormData?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .post, query: query, body: body.map(Body.multipart))
    }

    /// Creates a request suitable for a HTTP PUT with a `Encodable` body
    public static func put(_ path: Path, body: Encodable, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .put, query: query, body: .encodable(body))
    }

    /// Creates a request suitable for a HTTP PUT with a `MultipartFormData` body
    public static func put(_ path: Path, body: MultipartFormData, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .put, query: query, body: .multipart(body))
    }

    /// Create a HTTP PUT request with no body
    public static func put(_ path: Path, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .put, query: query, body: nil)
    }

    /// Creates a request suitable for a HTTP PATCH with a `Encodable` body
    public static func patch(_ path: Path, body: Encodable, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .patch, query: query, body: .encodable(body))
    }

    /// Creates a request suitable for a HTTP PATCH with a `MultipartFormData` body
    public static func patch(_ path: Path, body: MultipartFormData, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .patch, query: query, body: .multipart(body))
    }

    /// Creates a request suitable for a HTTP DELETE
    public static func delete(_ path: Path, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .delete, query: query, body: nil)
    }

    /// Creates a DELETE request with a Encodable body
    public static func delete(_ path: Path, body: Encodable, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .delete, query: query, body: nil)
    }

    /// Creates a Request.
    ///
    /// Use this init only if default provided static initializers (`.get`, `.post`, `.put`, `patch`, `.delete`) do not suit your needs.
    public init(path: Path, method: Method, query: [String: QueryParam], body: Body?) {
        self.path = path
        self.method = method
        self.body = body
        self.query = query
    }

    /// Adds headers to the request
    public func headers(_ newHeaders: [HTTPHeader: String]) -> Self {
        var request = self

        request.headers.merge(newHeaders) { $1 }

        return request
    }

    /// Configures request cache policy
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        var request = self

        request.cachePolicy = policy

        return request
    }
}
