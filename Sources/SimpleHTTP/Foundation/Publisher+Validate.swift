#if canImport(Combine)

import Foundation
import Combine

/// A function converting data when a http error occur into a custom error
public typealias DataErrorConverter = (Data) throws -> Error

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    /// validate publisher result optionally converting HTTP error into a custom one
    /// - Parameter converter: called when error is `HTTPError` and data was found in the output. Use it to convert
    /// data in a custom `Error` that will be returned of the http one.
    public func validate(_ converter: DataErrorConverter? = nil) -> AnyPublisher<Output, Error> {
        tryMap { output in
            do {
                try output.response.validate()
                return output
            }
            catch {
                if let _ = error as? HTTPError, let convert = converter, !output.data.isEmpty {
                    throw try convert(output.data)
                }
                
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
