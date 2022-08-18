import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URL {
    init<Output>(from request: Request<Output>) throws {
        guard var components = URLComponents(string: request.path) else {
            throw URLComponents.Error.invalid(path: request.path)
        }
        
        let queryItems = (components.queryItems ?? []) + request.query.queryItems
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw URLComponents.Error.cannotGenerateURL(components: components)
        }
        
        self = url
    }
}

extension URLComponents {
    public enum Error: Swift.Error {
        case invalid(path: String)
        case cannotGenerateURL(components: URLComponents)
    }
}

extension Dictionary where Key == String, Value == String {
    fileprivate var queryItems: [URLQueryItem]  {
        map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
