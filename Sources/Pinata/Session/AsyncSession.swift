import Foundation
import Combine

/// Primary class of the library used to perform http request using `Request`
@dynamicMemberLookup
public class AsyncSession {
    /// Data returned by a http request
    public typealias RequestData = (data: Data, response: URLResponse)

    /// a function returning `RequestData` for a `URLRequest`
    public typealias URLRequestTask = (URLRequest) async throws -> RequestData

    let baseURL: URL
    let config: SessionConfiguration
    /// a closure returning `RequestData` for a `URLRequest`
    let dataTask: URLRequestTask

    /// init the class using a `URLSession` instance
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter urlSession: `URLSession` instance to use to make requests.
    public convenience init(baseURL: URL, configuration: SessionConfiguration = .init(), urlSession: URLSession) {
        self.init(baseURL: baseURL, configuration: configuration, dataTask: urlSession.dataTask(with:))
    }

    /// init the class with a base url for request
    /// - Parameter baseURL: common url for all the requests. Allow to switch environments easily
    /// - Parameter configuration: session configuration to use
    /// - Parameter dataPublisher: publisher used by the class to make http requests. If none provided it default
    /// to `URLSession.dataPublisher(for:)`
    public init(
        baseURL: URL,
        configuration: SessionConfiguration = SessionConfiguration(),
        dataTask: @escaping URLRequestTask = URLSession.shared.dataTask(with:)
    ) {
        self.baseURL = baseURL
        self.config = configuration
        self.dataTask = dataTask
    }

    /// Return a publisher performing request and returning `Output` data
    ///
    /// The request is validated and decoded appropriately on success.
    /// - Returns: a Publisher emitting Output on success, an error otherwise
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

    /// Return a publisher performing request which has no return value
    public func response(for request: Request<Void>) async throws {
        let result = try await dataPublisher(for: request)
        log(.success(()), for: result.request)
    }
}

extension AsyncSession {
    private func dataPublisher<Output>(for request: Request<Output>) async throws -> Response<Output> {
        let adaptedRequest = config.interceptor.adaptRequest(request)

        let urlRequest = try adaptedRequest
            .toURLRequest(encoder: config.encoder)
            .relativeTo(baseURL)
            .settingHeaders([.accept: type(of: config.decoder).contentType.value])

        do {
            let result = try await dataTask(urlRequest)

            try (result.response as? HTTPURLResponse)?.validate()

            return Response(data: result.data, request: adaptedRequest)
        }
        catch {
            self.log(.failure(error), for: adaptedRequest)

            return try await self.rescue(error: error, request: request)
        }
    }

    private func log<Output>(_ response: Result<Output, Error>, for request: Request<Output>) {
        config.interceptor.receivedResponse(response, for: request)
    }

    subscript<T>(dynamicMember keyPath: KeyPath<SessionConfiguration, T>) -> T {
        config[keyPath: keyPath]
    }
}

private struct Response<Output> {
    let data: Data
    let request: Request<Output>
}

