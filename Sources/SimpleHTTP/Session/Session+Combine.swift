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
