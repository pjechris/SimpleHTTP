import Foundation
import Combine

#if canImport(_Concurrency)

extension Session {
    public func response<Output: Decodable>(for request: Request<Output>) async throws -> Output {
       try await response(publisher: publisher(for: request))
    }
    
    public func response(for request: Request<Void>) async throws {
        try await response(publisher: publisher(for: request))
    }
    
    private func response<Output>(publisher: AnyPublisher<Output, Error>) async throws -> Output {
        var cancellable: Set<AnyCancellable> = []
        let onCancel = { cancellable.removeAll() }
        
        return try await withTaskCancellationHandler(
            handler: { onCancel() },
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    publisher
                        .sink(
                            receiveCompletion: {
                                if case let .failure(error) = $0 {
                                    return continuation.resume(throwing: error)
                                }
                            },
                            receiveValue: {
                                continuation.resume(returning: $0)
                            })
                        .store(in: &cancellable)
                }
            })
    }
}

#endif
