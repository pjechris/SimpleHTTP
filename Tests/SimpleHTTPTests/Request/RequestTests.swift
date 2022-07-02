import XCTest
@testable import SimpleHTTP

class RequestTests: XCTestCase {
    enum TestEndpoint: String, Path {
        case test
    }
    
    let baseURL = URL(string: "https://google.fr")!
    
    func test_init_withPathAsString() {
        XCTAssertEqual(Request<Void>.get("hello_world").path, "hello_world")
    }
    
    func test_toURLRequest_setHttpMethod() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: nil)
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)
        
        XCTAssertEqual(request.httpMethod, "POST")
    }

    func test_toURLRequest_itEncodeBody() throws {
      let request = try Request<Void>.post(TestEndpoint.test, body: .encodable(Body()))
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)

      XCTAssertEqual(request.httpBody, try JSONEncoder().encode(Body()))
    }

    func test_toURLRequest_itMultipartBody() throws {
      let crlf = EncodingCharacters.crlf
      let boundary = "boundary"
      var multipart = MultipartFormData(boundary: boundary)
      let url = try url(forResource: "swift", withExtension: "png")
      let name = "swift"
      try multipart.add(url: url, name: name)

      let request = try Request<Void>.post(TestEndpoint.test, body: .multipart(multipart))
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)

      /// We can't use  `XCTAssertEqual(request.httpBody, try multipart.encode)`
      /// The `encode` method is executed to fast and rase and error
      var body = Data()
      body.append(Boundary.data(for: .initial, boundary: boundary))
      body.append(
        Data((
          "Content-Disposition: form-data; name=\"\(name)\"; filename=\"swift.png\"\(crlf)"
            + "Content-Type: image/png\(crlf)\(crlf)"
        ).utf8)
      )
      body.append(try Data(contentsOf: url))
      body.append(Boundary.data(for: .final, boundary: boundary))
      XCTAssertEqual(request.httpBody, body)
    }

    func test_toURLRequest_bodyIsEncodable_itFillDefaultHeaders() throws {
      let request = try Request<Void>.post(TestEndpoint.test, body: .encodable(Body()))
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)

      XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func test_toURLRequest_bodyIsMultipart_itFillDefaultHeaders() throws {
      let boundary = "boundary"
      var multipart = MultipartFormData(boundary: boundary)
      let url = try url(forResource: "swift", withExtension: "png")
      let name = "swift"
      try multipart.add(url: url, name: name)

      let request = try Request<Void>.post(TestEndpoint.test, body: .multipart(multipart))
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)

      XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], multipart.contentType.value)
    }
    
}

private struct Body: Encodable {
    
}
