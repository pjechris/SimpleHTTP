import Foundation
import XCTest
@testable import SimpleHTTP

class URLRequestTests: XCTestCase {
    func test_initFromRequest_pathIsSetted() throws {
        XCTAssertEqual(
            try URL(from: Request<Void>.get("test")).path,
            "test"
        )
    }

    func test_initFromRequest_pathHasQueryItems_urlQueryIsSetted() throws {
        XCTAssertEqual(
            try URL(from: Request<Void>.get("hello/world?test=1")).query,
            "test=1"
        )
    }

    func test_initFromRequest_whenPathHasQueryItems_urlPathHasNoQuery() throws {
        XCTAssertEqual(
            try URL(from: Request<Void>.get("hello/world?test=1")).path,
            "hello/world"
        )
    }
}
