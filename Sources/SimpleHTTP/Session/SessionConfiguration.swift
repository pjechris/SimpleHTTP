import Foundation

/// a type defining some parameters for a `Session`
public struct SessionConfiguration {
    /// data encoders/decoders configuration per content type
    let data: ContentDataCoderConfiguration
    /// queue on which to decode data
    let decodingQueue: DispatchQueue
    /// an interceptor to apply custom behavior on the session requests/responses.
    /// To apply multiple interceptors use `ComposeInterceptor`
    let interceptor: Interceptor
    /// a function decoding data as a custom error given the response content type
    private(set) var errorConverter: ContentDataErrorDecoder?

    /// - Parameter data: encoders/decoders configuration per content type
    /// - Parameter decodeQueue: queue on which to decode data
    /// - Parameter interceptors: interceptor list to apply on the session requests/responses
    public init(
        data: ContentDataCoderConfiguration = .init(),
        decodingQueue: DispatchQueue = .main,
        interceptors: CompositeInterceptor = []) {
            self.data = data
            self.decodingQueue = decodingQueue
            self.interceptor = interceptors
        }

    /// - Parameter dataError: Error type to use when having error with data
    public init<DataError: Error & Decodable>(
        data: ContentDataCoderConfiguration,
        decodingQueue: DispatchQueue = .main,
        interceptors: CompositeInterceptor = [],
        dataError: DataError.Type
    ) {
        self.init(data: data, decodingQueue: decodingQueue, interceptors: interceptors)
        self.errorConverter = { [decoder=data.decoder] data, contentType in
            guard let decoder = decoder[contentType] else {
                throw SessionConfigurationError.missingDecoder(contentType)
            }
            return try decoder.decode(dataError, from: data)
        }
    }
}

public enum SessionConfigurationError: Error {
    case missingEncoder(HTTPContentType)
    case missingDecoder(HTTPContentType)
}
