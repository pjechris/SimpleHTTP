import Foundation

public enum Method: String {
    case get
    case post
    case put
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
    /// request relative endpoint
    public let endpoint: Endpoint
    public let method: Method
    public let body: Body?
    public let query: [String: QueryParam]
    public private(set) var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    public private(set) var headers: HTTPHeaderFields = [:]
    
    /// Creates a request suitable for a HTTP GET
    public static func get(_ endpoint: Endpoint, query: [String: QueryParam] = [:]) -> Self {
        self.init(endpoint: endpoint, method: .get, query: query, body: nil)
    }
    
    /// Creates a request suitable for a HTTP POST with an optional `Body`
    public static func post(_ endpoint: Endpoint, body: Body?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(endpoint: endpoint, method: .post, query: query, body: body)
    }
    
    /// Creates a request suitable for a HTTP POST with a `Encodable` body
    public static func post(_ endpoint: Endpoint, body: Encodable, query: [String: QueryParam] = [:])
    -> Self {
        self.post(endpoint, body: .encodable(body), query: query)
    }
    
    /// Creates a request suitable for a HTTP POST with a `MultipartFormData` body
    public static func post(_ endpoint: Endpoint, body: MultipartFormData, query: [String: QueryParam] = [:])
    -> Self {
        self.post(endpoint, body: .multipart(body), query: query)
    }
    
    /// Creates a request suitable for a HTTP PUT with a `Body` body
    public static func put(_ endpoint: Endpoint, body: Body?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(endpoint: endpoint, method: .put, query: query, body: body)
    }
    
    /// Creates a request suitable for a HTTP PUT with a `Encodable` body
    public static func put(_ endpoint: Endpoint, body: Encodable, query: [String: QueryParam] = [:])
    -> Self {
        self.put(endpoint, body: .encodable(body), query: query)
    }
    
    /// Creates a request suitable for a HTTP PUT with a `MultipartFormData` body
    public static func put(_ endpoint: Endpoint, body: MultipartFormData, query: [String: QueryParam] = [:])
    -> Self {
        self.put(endpoint, body: .multipart(body), query: query)
    }
    
    /// Creates a request suitable for a HTTP DELETE
    public static func delete(_ endpoint: Endpoint, query: [String: QueryParam] = [:]) -> Self {
        self.init(endpoint: endpoint, method: .delete, query: query, body: nil)
    }
    
    private init(endpoint: Endpoint, method: Method, query: [String: QueryParam], body: Body?) {
        self.endpoint = endpoint
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
