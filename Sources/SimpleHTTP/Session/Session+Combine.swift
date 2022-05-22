import Foundation

#if canImport(Combine)
import Combine

extension Session {
    /// Return a publisher performing request and returning `Output` data
    ///
    /// The request is validated and decoded appropriately on success.
    /// - Returns: a Publisher emitting Output on success, an error otherwise
    public func publisher<Output: Decodable>(for request: Request<Output>) -> AnyPublisher<Output, Error> {
        let subject = PassthroughSubject<Output, Error>()
        
        Task {
            do {
                subject.send(try await response(for: request))
                subject.send(completion: .finished)
            }
            catch {
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    public func publisher(for request: Request<Void>) -> AnyPublisher<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()
        
        Task {
            do {
                subject.send(try await response(for: request))
                subject.send(completion: .finished)
            }
            catch {
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}

#endif

//#if canImport(_Concurrency)
//
//extension Session {
//    public func response<Output: Decodable>(for request: Request<Output>) async throws -> Output {
//       try await response(publisher: publisher(for: request))
//    }
//
//    public func response(for request: Request<Void>) async throws {
//        try await response(publisher: publisher(for: request))
//    }
//
//    private func response<Output>(publisher: AnyPublisher<Output, Error>) async throws -> Output {
//        var cancellable: Set<AnyCancellable> = []
//        let onCancel = { cancellable.removeAll() }
//
//        return try await withTaskCancellationHandler(
//            handler: { onCancel() },
//            operation: {
//                try await withCheckedThrowingContinuation { continuation in
//                    publisher
//                        .sink(
//                            receiveCompletion: {
//                                if case let .failure(error) = $0 {
//                                    return continuation.resume(throwing: error)
//                                }
//                            },
//                            receiveValue: {
//                                continuation.resume(returning: $0)
//                            })
//                        .store(in: &cancellable)
//                }
//            })
//    }
//}
//
//#endif
