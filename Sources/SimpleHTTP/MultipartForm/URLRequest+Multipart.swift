import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    public mutating func multipartBody(_ body: MultipartFormData) throws {
        var multipartEncode = MultipartFormDataEncoder(body: body)

        httpBody = try multipartEncode.encode()

        setHeaders([.contentType: HTTPContentType.multipart(boundary: body.boundary).value])
    }
}
