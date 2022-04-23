import Foundation
import Combine

/// Primary class of the library used to perform http request using a `Request` object
public class AsyncSession {
    /// Data returned by a http request
    public typealias DataResponse = (data: Data, response: URLResponse)

    /// a function returning a `RequestData` from a `URLRequest`
    public typealias URLRequestTask = (URLRequest) async throws -> DataResponse

    let baseURL: URL
    let config: SessionConfiguration
    /// a closure returning a `DataResponse` from a `URLRequest`
    let dataTask: URLRequestTask

    /// init the class using a `URLSession` instance
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter urlSession: `URLSession` instance to use to make requests.
    public convenience init(baseURL: URL, configuration: SessionConfiguration = .init(), urlSession: URLSession = .shared) {
        self.init(baseURL: baseURL, configuration: configuration, dataTask: { try await urlSession.data(for: $0) })
    }

    /// init the class with a base url for request
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter dataTask: publisher used by the class to make http requests. If none provided it default
    /// to `URLSession.dataPublisher(for:)`
    public init(baseURL: URL, configuration: SessionConfiguration = SessionConfiguration(), dataTask: @escaping URLRequestTask) {
        self.baseURL = baseURL
        self.config = configuration
        self.dataTask = dataTask
    }

    /// Return a publisher performing `request` and returning `Output`
    ///
    /// The request is validated and decoded appropriately on success.
    /// - Returns: a async Output on success, an error otherwise
    public func response<Output: Decodable>(for request: Request<Output>) async throws -> Output {
        let result = try await dataPublisher(for: request)

        do {
            let decodedOutput = try config.decoder.decode(Output.self, from: result.data)
            let output = try config.interceptor.adaptOutput(decodedOutput, for: result.request)

            log(.success(output), for: result.request)
            return output
        }
        catch {
            log(.failure(error), for: result.request)
            throw error
        }
    }

    /// Perform asynchronously `request` which has no return value
    public func response(for request: Request<Void>) async throws {
        let result = try await dataPublisher(for: request)
        log(.success(()), for: result.request)
    }
}

extension AsyncSession {
    private func dataPublisher<Output>(for request: Request<Output>) async throws -> Response<Output> {
        let adaptedRequest = config.interceptor.adaptRequest(request)
        let urlRequest = try adaptedRequest.toURLRequest(encoder: config.encoder, relativeTo: baseURL, accepting: config.decoder)

        do {
            let result = try await dataTask(urlRequest)

            try (result.response as? HTTPURLResponse)?.validate()

            return Response(data: result.data, request: adaptedRequest)
        }
        catch {
            self.log(.failure(error), for: adaptedRequest)

          if try await config.interceptor.rescueRequest(request, error: error) {
            return try await dataPublisher(for: request)
          }

          throw error
        }
    }

    private func log<Output>(_ response: Result<Output, Error>, for request: Request<Output>) {
        config.interceptor.receivedResponse(response, for: request)
    }
}

private struct Response<Output> {
    let data: Data
    let request: Request<Output>
}

