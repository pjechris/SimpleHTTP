import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    /// Transform a Request into a URLRequest
    /// - Parameter encoder: the encoder to use to encode the body is present
    /// - Parameter relativeTo: the base URL to append to the request path
    /// - Parameter accepting: if not nil will be used to set "Accept" header value
    public func toURLRequest(encoder: ContentDataEncoder, relativeTo baseURL: URL, accepting: ContentDataDecoder? = nil) throws -> URLRequest {
        let request = try toURLRequest(encoder: encoder)
            .relativeTo(baseURL)

        if let decoder = accepting {
            return request.settingHeaders([.accept: type(of: decoder).contentType.value])
        }
        
        return request
    }

    private func toURLRequest(encoder: ContentDataEncoder) throws -> URLRequest {
        var urlRequest = try URLRequest(url: URL(from: self))
        
        urlRequest.httpMethod = method.rawValue.uppercased()
        urlRequest.cachePolicy = cachePolicy
        urlRequest.setHeaders(headers)
        
        if let body = body {
            switch body {
            case .encodable(let body):
                try urlRequest.encodeBody(body, encoder: encoder)
            case .multipart(let multipart):
                try urlRequest.multipartBody(multipart)
            }
        }
        
        return urlRequest
    }

    
}

