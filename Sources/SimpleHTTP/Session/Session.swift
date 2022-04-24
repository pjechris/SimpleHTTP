import Foundation
import Combine

/// Primary class of the library used to perform http request using `Request` objects
public class Session {
    /// Data returned by a http request
    public typealias RequestData = URLSession.DataTaskPublisher.Output
    
    /// a Publisher emitting `RequestData`
    public typealias RequestDataPublisher = AnyPublisher<RequestData, Error>
    
    let baseURL: URL
    let config: SessionConfiguration
    /// a closure returning a publisher based for a given `URLRequest`
    let urlRequestPublisher: (URLRequest) -> RequestDataPublisher
    
    /// init the class using a `URLSession` instance
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter urlSession: `URLSession` instance to use to make requests.
    public convenience init(baseURL: URL, configuration: SessionConfiguration = .init(), urlSession: URLSession) {
        self.init(
            baseURL: baseURL,
            configuration: configuration,
            dataPublisher: urlSession.dataPublisher(for:)
        )
    }
    
    /// init the class with a base url for request
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter dataPublisher: publisher used by the class to make http requests. If none provided it default
    /// to `URLSession.dataPublisher(for:)`
    public init(
        baseURL: URL,
        configuration: SessionConfiguration = SessionConfiguration(),
        dataPublisher: @escaping (URLRequest) -> RequestDataPublisher = { URLSession.shared.dataPublisher(for: $0) }
    ) {
        self.baseURL = baseURL
        self.config = configuration
        self.urlRequestPublisher = dataPublisher
    }
    
    /// Return a publisher performing request and returning `Output` data
    ///
    /// The request is validated and decoded appropriately on success.
    /// - Returns: a Publisher emitting Output on success, an error otherwise
    public func publisher<Output: Decodable>(for request: Request<Output>) -> AnyPublisher<Output, Error> {
        dataPublisher(for: request)
            .receive(on: config.decodingQueue)
            .map { response -> (output: Result<Output, Error>, request: Request<Output>) in
                let output = Result {
                    try self.config.interceptor.adaptOutput(
                        try self.config.decoder.decode(Output.self, from: response.data),
                        for: response.request
                    )
                }
                
                return (output: output, request: response.request)
            }
            .handleEvents(receiveOutput: { self.log($0.output, for: $0.request) })
            .tryMap { try $0.output.get() }
            .eraseToAnyPublisher()
    }
    
    /// Return a publisher performing request which has no return value
    public func publisher(for request: Request<Void>) -> AnyPublisher<Void, Error> {
        dataPublisher(for: request)
            .handleEvents(receiveOutput: { self.log(.success(()), for: $0.request) })
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension Session {
    private func dataPublisher<Output>(for request: Request<Output>) -> AnyPublisher<Response<Output>, Error> {
        let adaptedRequest = config.interceptor.adaptRequest(request)
        
        do {
            let urlRequest = try adaptedRequest
                .toURLRequest(encoder: config.encoder, relativeTo: baseURL, accepting: config.decoder)
            
            return urlRequestPublisher(urlRequest)
                .validate(config.errorConverter)
                .map { Response(data: $0.data, request: adaptedRequest) }
                .handleEvents(receiveCompletion: { self.logIfFailure($0, for: adaptedRequest) })
                .tryCatch { try self.rescue(error: $0, request: request) }
                .eraseToAnyPublisher()
        }
        catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    /// log a request completion
    private func logIfFailure<Output>(_ completion: Subscribers.Completion<Error>, for request: Request<Output>) {
        if case .failure(let error) = completion {
            config.interceptor.receivedResponse(.failure(error), for: request)
        }
    }
    
    private func log<Output>(_ response: Result<Output, Error>, for request: Request<Output>) {
        config.interceptor.receivedResponse(response, for: request)
    }
    
    /// try to rescue an error while making a request and retry it when rescue suceeded
    private func rescue<Output>(error: Error, request: Request<Output>) throws -> AnyPublisher<Response<Output>, Error> {
        guard let rescue = config.interceptor.rescueRequest(request, error: error) else {
            throw error
        }
        
        return rescue
            .map { self.dataPublisher(for: request) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

private struct Response<Output> {
    let data: Data
    let request: Request<Output>
}
