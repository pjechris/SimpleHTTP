import Foundation

public struct URLDataResponse: Sendable {
    public let data: Data
    public let response: HTTPURLResponse

    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
}

extension URLDataResponse {
    public func validate(errorDecoder: DataErrorDecoder? = nil) throws {
        do {
            try response.validate()
        }
        catch let error as HTTPError {
            guard let decoder = errorDecoder, !data.isEmpty else {
                throw error
            }

            throw try decoder(data)
        }
    }
}
