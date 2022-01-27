import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
    func encodedBody<T: Encodable>(_ body: T, encoder: JSONEncoder) throws -> Self {
        var request = self
        
        try request.encodeBody(body, encoder: encoder)
        
        return request
    }
    
    /// Use a `JSONEncoder` object as request body and set the "Content-Type" header associated to the encoder
    mutating func encodeBody<T: Encodable>(_ body: T, encoder: JSONEncoder) throws {
        httpBody = try encoder.encode(body)
        setValue("Content-Type", forHTTPHeaderField: "application/json")
    }
    
}
