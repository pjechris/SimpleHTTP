import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    public func data(for urlRequest: URLRequest) async throws -> URLDataResponse {
        let (data, response) = try await data(for: urlRequest)

        return URLDataResponse(data: data, response: response as! HTTPURLResponse)
    }
}
