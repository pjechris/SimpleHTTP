import XCTest
import Pinata

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class URLResponseValidateTests: XCTest {
    let url = URL(string: "/")!
    
    func test_validate_statusCodeIsOK_itThrowNoError() throws {
        try HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!.validate()
    }
    
    // we should never have redirection that's why we consider it as an error
    func test_validate_statusCodeIsRedirection_itThrow() {
        XCTAssertThrowsError(
            try HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)!.validate()
        )
    }
    
    func test_validate_statusCodeIsClientError_itThrow() {
        XCTAssertThrowsError(
            try HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!.validate()
        )
    }
}
