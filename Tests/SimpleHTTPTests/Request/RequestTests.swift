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
    
    func test_toURLRequest_encodeBody() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: Body())
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)
        
        XCTAssertEqual(request.httpBody, try JSONEncoder().encode(Body()))
    }
    
    func test_toURLRequest_fillDefaultHeaders() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: Body())
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
    func test_toURLRequest_absoluteStringIsBaseURLPlusPath() throws {
        let request = try Request<Void>.get(TestEndpoint.test)
            .toURLRequest(encoder: JSONEncoder(), relativeTo: baseURL)
        
        XCTAssertEqual(request.url?.absoluteString, baseURL.absoluteString + "/test")
    }
    
}

private struct Body: Encodable {
    
}
