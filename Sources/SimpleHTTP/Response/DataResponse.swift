import Foundation

public struct URLDataResponse {
    public let data: Data
    public let response: HTTPURLResponse
}

extension URLDataResponse {
    public func validate(errorDecoder: DataErrorDecoder? = nil) throws {
        do {
            try response.validateStatusCode()
        }
        catch let error as HTTPError {
            guard let decoder = errorDecoder, !data.isEmpty else {
                throw error
            }
            
            throw try decoder(data)
        }
    }
}
