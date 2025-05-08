import Foundation

public typealias Interceptor = RequestInterceptor & ResponseInterceptor

/// a protocol intercepting a session request
public protocol RequestInterceptor {
    /// Should be called before making the request to provide modifications to `request`
    func adaptRequest<Output>(_ request: Request<Output>) async throws -> Request<Output>

    /// catch and retry a failed request
    /// - Returns: nil if the request should not be retried. Otherwise a publisher that will be executed before
    /// retrying the request
    func shouldRescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool
}

/// a protocol intercepting a session response
public protocol ResponseInterceptor {
    /// Should be called once the request is done and output was received. Let one last chance to modify the output
    /// optionally throwing an error instead if needed
    /// - Parameter request: the request that was sent to the server
    func adaptOutput<Output>(_ output: Output, for request: Request<Output>) throws -> Output

    /// Notify of received response for `request`
    /// - Parameter request: the request that was sent to the server
    func receivedResponse<Output>(_ result: Result<Output, Error>, for request: Request<Output>)
}
