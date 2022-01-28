import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    init<Output>(from request: Request<Output>, encoder: ContentDataEncoder) throws {
        self = try URLRequest(url: URL(from: request))
        
        httpMethod = request.method.rawValue.uppercased()
        setHeaders(request.headers)
        
        if let body = request.body {
            try encodeBody(body, encoder: encoder)
        }
    }
}
