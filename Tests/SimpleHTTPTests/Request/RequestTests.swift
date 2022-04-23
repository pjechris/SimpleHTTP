import XCTest
@testable import SimpleHTTP

class RequestTests: XCTestCase {
    enum TestEndpoint: String, Path {
        case test
    }
    
    func test_init_withPathAsString() {
        XCTAssertEqual(Request<Void>.get("hello_world").path, "hello_world")
    }
    
    func test_toURLRequest_itSetHttpMethod() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: nil)
            .toURLRequest(encoder: JSONEncoder())
        
        XCTAssertEqual(request.httpMethod, "POST")
    }
    
    func test_toURLRequest_itEncodeBody() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: Body())
            .toURLRequest(encoder: JSONEncoder())
        
        XCTAssertEqual(request.httpBody, try JSONEncoder().encode(Body()))
    }
    
    func test_toURLRequest_itFillDefaultHeaders() throws {
        let request = try Request<Void>.post(TestEndpoint.test, body: Body())
            .toURLRequest(encoder: JSONEncoder())
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
}

private struct Body: Encodable {
    
}
