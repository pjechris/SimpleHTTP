import Foundation
import Combine

/// Use an Array of `Interceptor` as a single `Interceptor`
public struct CompositeInterceptor: ExpressibleByArrayLiteral, Sequence {
    let interceptors: [Interceptor]

    public init(arrayLiteral interceptors: Interceptor...) {
        self.interceptors = interceptors
    }

    public func makeIterator() -> Array<Interceptor>.Iterator {
        interceptors.makeIterator()
    }
}

extension CompositeInterceptor: Interceptor {
    public func adaptRequest<Output>(_ request: Request<Output>) async -> Request<Output> {
        var request = request
        for interceptor in interceptors {
            request = await interceptor.adaptRequest(request)
        }

        return request
    }

    public func shouldRescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool {
        for interceptor in interceptors where try await interceptor.shouldRescueRequest(request, error: error) {
            return true
        }

        return false
    }

    public func adaptOutput<Output>(_ response: Output, for request: Request<Output>) throws -> Output {
        try reduce(response) { response, interceptor in
            try interceptor.adaptOutput(response, for: request)
        }
    }

    public func receivedResponse<Output>(_ result: Result<Output, Error>, for request: Request<Output>) {
        forEach { interceptor in
            interceptor.receivedResponse(result, for: request)
        }
    }
}
