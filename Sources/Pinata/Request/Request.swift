import Foundation

public enum Method: String {
    case get
    case post
    case put
    case delete
}

/// An Http request expecting an `Output` response
///
/// Highly inspired by https://swiftwithmajid.com/2021/02/10/building-type-safe-networking-in-swift/
public struct Request<Output> {
    
    /// request relative path
    public let path: String
    public let method: Method
    public let body: Encodable?
    public let parameters: [String: String]
    public private(set) var headers: [String: String] = [:]
    
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
    
    public mutating func headers(_ headers: [String: String]) -> Self {
        self.headers.merge(headers) { $1 }
        return self
    }
    
    private init(path: Path, method: Method, parameters: [String: String] = [:], body: Encodable?) {
        self.path = path.path
        self.method = method
        self.body = body
        self.parameters = parameters
    }
    
}
