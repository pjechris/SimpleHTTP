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
    
    /// request relative path
    public let path: String
    public let method: Method
    public let body: Body?
    public let query: [String: QueryParam]
    public private(set) var headers: HTTPHeaderFields = [:]
    
    public static func get(_ path: Path, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .get, query: query, body: nil)
    }
    
    public static func post(_ path: Path, body: Body?, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .post, query: query, body: body)
    }
    
    public static func put(_ path: Path, body: Body, query: [String: QueryParam] = [:])
    -> Self {
        self.init(path: path, method: .put, query: query, body: body)
    }
    
    public static func delete(_ path: Path, query: [String: QueryParam] = [:]) -> Self {
        self.init(path: path, method: .delete, query: query, body: nil)
    }
    
    private init(path: Path, method: Method, query: [String: QueryParam], body: Body?) {
        self.path = path.path
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
