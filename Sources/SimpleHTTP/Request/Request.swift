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

/// A Http request expecting an `Output` response
///
/// Highly inspired by https://swiftwithmajid.com/2021/02/10/building-type-safe-networking-in-swift/
public struct Request<Output> {
    
    /// request relative endpoint
    public let endpoint: Endpoint
    public let method: Method
    public let body: Body?
    public let query: [String: QueryParam]
    public private(set) var headers: HTTPHeaderFields = [:]
    
    public static func get(_ endpoint: Endpoint, query: [String: QueryParam] = [:]) -> Self {
        self.init(endpoint: endpoint, method: .get, query: query, body: nil)
    }
    
    public static func post(_ endpoint: Endpoint, body: Body?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(endpoint: endpoint, method: .post, query: query, body: body)
    }
    
    public static func put(_ endpoint: Endpoint, body: Body, query: [String: QueryParam] = [:])
    -> Self {
        self.init(endpoint: endpoint, method: .put, query: query, body: body)
    }
    
    public static func delete(_ endpoint: Endpoint, query: [String: QueryParam] = [:]) -> Self {
        self.init(endpoint: endpoint, method: .delete, query: query, body: nil)
    }
    
    private init(endpoint: Endpoint, method: Method, query: [String: QueryParam], body: Body?) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.query = query
    }
    
    /// add headers to the request
    public func headers(_ newHeaders: [HTTPHeader: String]) -> Self {
        var request = self
        
        request.headers.merge(newHeaders) { $1 }
        
        return request
    }
}
