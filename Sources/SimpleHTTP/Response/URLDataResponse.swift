import Foundation

/// a `HTTPURLResponse` and its raw response
public struct URLDataResponse {
    public let data: Data
    public let response: HTTPURLResponse
}

extension URLDataResponse {    
    public func validate(errorDecoder: DataErrorDecoder? = nil) throws -> Response<Data> {
        do {
            try response.validateStatusCode()
            
            return Response(output: data, statusCode: response.statusCode, headers: [:])
        }
        catch let error as HTTPError {
            guard let decoder = errorDecoder, !data.isEmpty else {
                throw error
            }
            
            throw try decoder(data)
        }
    }    
}
