import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPURLResponse {
  convenience init(statusCode: Int) {
    self.init(url: URL(string: "/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }
}

extension URLResponse {
  static let success = HTTPURLResponse(statusCode: 200)
  static let unauthorized = HTTPURLResponse(statusCode: 401)
  static let notFound = HTTPURLResponse(statusCode: 404)
}
