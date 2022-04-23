import Foundation

/// A encoder suited to encode to Data
public protocol DataEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

/// A decoder suited to decode Data
public protocol DataDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

/// A `DataEncoder` providing a `ContentType`
public protocol ContentDataEncoder: DataEncoder {
    /// a http content  type
    static var contentType: HTTPContentType { get }
}

/// A `DataDecoder` providing a `ContentType`
public protocol ContentDataDecoder: DataDecoder {
    /// a http content  type
    static var contentType: HTTPContentType { get }
}
