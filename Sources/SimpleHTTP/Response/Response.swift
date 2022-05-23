import Foundation

/// A valid HTTP output and metadata
public struct Response<Output> {
    public let output: Output
    /// http response status code. As this object is only built after validating status code is 200..<400 you're assured
    /// it does not contain any error value
    public let statusCode: Int
    public let headers: HTTPHeaderFields
}

extension Response {
    public func map<T>(_ transform: (Output) throws -> T) rethrows -> Response<T> {
        Response<T>(
            output: try transform(output),
            statusCode: statusCode,
            headers: headers
        )
    }
}

extension Response where Output == Data {
    public func decoded<T: Decodable>(_ type: T.Type, decoder: DataDecoder) throws -> Response<T> {
        try map { try decoder.decode(type, from: $0) }
    }
}
