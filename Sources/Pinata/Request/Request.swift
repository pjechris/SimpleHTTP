import Foundation

public enum Method: String {
    case get
    case post
    case put
    case delete
}

/// A Http request expecting an `Output` response
///
/// Highly inspired by https://swiftwithmajid.com/2021/02/10/building-type-safe-networking-in-swift/
public struct Request<Output> {
    
    /// request relative path
    public let path: String
    public let method: Method
    public let body: Encodable?
    public let parameters: [String: String]
    public private(set) var headers: HTTPHeaderFields = [:]
    
    public static func get(_ path: Path, parameters: [String: String] = [:]) -> Self {
        self.init(path: path, method: .get, parameters: parameters, body: nil)
    }
    
    public static func post(_ path: Path, body: Encodable?, parameters: [String: String] = [:])
    -> Self {
        self.init(path: path, method: .post, parameters: parameters, body: body)
    }
    
    public static func put(_ path: Path, body: Encodable, parameters: [String: String] = [:])
    -> Self {
        self.init(path: path, method: .put, parameters: parameters, body: body)
    }
    
    public static func delete(_ path: Path, parameters: [String: String] = [:]) -> Self {
        self.init(path: path, method: .delete, parameters: parameters, body: nil)
    }
    
    private init(path: Path, method: Method, parameters: [String: String] = [:], body: Encodable?) {
        self.path = path.path
        self.method = method
        self.body = body
        self.parameters = parameters
    }
    
    /// add headers to the request
    public func headers(_ newHeaders: [HTTPHeader: String]) -> Self {
        var request = self
        
        request.headers.merge(newHeaders) { $1 }
        
        return request
    }
}
