import XCTest
import Pinata

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class URLRequestEncodeTests: XCTest {
    
    func test_encodedBody_itSetContentTypeHeader() throws {
        let body: [String:String] = [:]
        let request = try URLRequest(url: URL(string: "/")!)
            .encodedBody(body, encoder: JSONEncoder())
        
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
}
