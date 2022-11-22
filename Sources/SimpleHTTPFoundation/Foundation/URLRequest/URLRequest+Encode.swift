import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    public func encodedBody(_ body: Encodable, encoder: ContentDataEncoder) throws -> Self {
        var request = self

        try request.encodeBody(body, encoder: encoder)

        return request
    }

    /// Use a `Encodable` object as request body and set the "Content-Type" header associated to the encoder
    public mutating func encodeBody(_ body: Encodable, encoder: ContentDataEncoder) throws {
        httpBody = try body.encoded(with: encoder)
        setHeaders([.contentType: type(of: encoder).contentType.value])
    }

}
