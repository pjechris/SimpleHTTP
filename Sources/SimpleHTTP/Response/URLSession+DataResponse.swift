import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    public func data(for urlRequest: URLRequest) async throws -> URLDataResponse {
        let (data, response) = try await data(for: urlRequest)

        // swiftlint:disable force_cast
        return URLDataResponse(data: data, response: response as! HTTPURLResponse)
        // swiftlint:enable force_cast
    }
}
