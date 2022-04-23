import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    func toURLRequest(encoder: ContentDataEncoder) throws -> URLRequest {
        var urlRequest = try URLRequest(url: URL(from: self))
        
        urlRequest.httpMethod = method.rawValue.uppercased()
        urlRequest.setHeaders(headers)
        
        if let body = body {
            try urlRequest.encodeBody(body, encoder: encoder)
        }
        
        return urlRequest
    }
}

