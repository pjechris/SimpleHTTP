import Foundation

extension URLSession {
    /// Return a dataTaskPublisher as a `DataPublisher`
    public func dataPublisher(for request: URLRequest) -> Session.RequestDataPublisher {
        dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
