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
    public func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
        reduce(request) { request, interceptor in
            interceptor.adaptRequest(request)
        }
    }
    
    public func rescueRequest<Output>(_ request: Request<Output>, error: Error) -> AnyPublisher<Void, Error>? {
        let publishers = compactMap { $0.rescueRequest(request, error: error) }
        
        guard !publishers.isEmpty else {
            return nil
        }
        
        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }

  public func rescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool {
    try await withThrowingTaskGroup(of: Bool.self) { group in
      var rescue = false

      for interceptor in interceptors {
        group.addTask(priority: .background) {
          try await interceptor.rescueRequest(request, error: error)
        }
      }

      for try await interceptorRescued in group {
        rescue = rescue || interceptorRescued
      }

      return rescue
    }
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
