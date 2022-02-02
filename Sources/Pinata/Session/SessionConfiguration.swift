import Foundation

/// a type defining some parameters for a `Session`
public struct SessionConfiguration {
    /// encoder to use for request bodies
    let encoder: ContentDataEncoder
    /// decoder used to decode http responses
    let decoder: ContentDataDecoder
    /// queue on which to decode data
    let decodingQueue: DispatchQueue
    /// an interceptor to apply custom behavior on the session requests/responses.
    /// To apply multiple interceptors use `ComposeInterceptor`
    let interceptor: Interceptor
    /// a function decoding data (using `decoder`) as a custom error
    private(set) var errorConverter: DataErrorConverter?
    
    /// - Parameter encoder to use for request bodies
    /// - Parameter decoder used to decode http responses
    /// - Parameter decodeQueue: queue on which to decode data
    /// - Parameter interceptors: interceptor list to apply on the session requests/responses
    public init(
        encoder: ContentDataEncoder = JSONEncoder(),
        decoder: ContentDataDecoder = JSONDecoder(),
        decodingQueue: DispatchQueue = .main,
        interceptors: CompositeInterceptor = []) {
            self.encoder = encoder
            self.decoder = decoder
            self.decodingQueue = decodingQueue
            self.interceptor = interceptors
        }
    
    /// - Parameter dataError: Error type to use when having error with data
    public init<DataError: Error & Decodable>(
        encoder: ContentDataEncoder = JSONEncoder(),
        decoder: ContentDataDecoder = JSONDecoder(),
        decodingQueue: DispatchQueue = .main,
        interceptors: CompositeInterceptor = [],
        dataError: DataError.Type
    ) {
        self.init(encoder: encoder, decoder: decoder,  decodingQueue: decodingQueue, interceptors: interceptors)
        self.errorConverter = {
            try decoder.decode(dataError, from: $0)
        }
    }
}
