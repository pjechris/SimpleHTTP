import Foundation
import XCTest
@testable import SimpleHTTPFoundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class URLRequestURLTests: XCTestCase {
    func test_relativeTo_requestURLHasBaseURL() {
        let request = URLRequest(url: URL(string: "path")!)
        let url = request.relativeTo(URL(string: "https://google.com")!).url

        XCTAssertEqual(url?.absoluteString, "https://google.com/path")
    }

    func test_relativeTo_urlStartWithSlash_requestPathContainBothPaths() {
        let request = URLRequest(url: URL(string: "/path")!)
        let url = request.relativeTo(URL(string: "https://google.com/lostAndFound")!).url

        XCTAssertEqual(url?.absoluteString, "https://google.com/lostAndFound/path")
    }

    func test_relativeTo_baseURLHasPath_requestContainBaseURLPath() {
        let request = URLRequest(url: URL(string: "concatenated")!)
        let url = request.relativeTo(URL(string: "https://google.com/firstPath")!).url

        XCTAssertEqual(url?.absoluteString, "https://google.com/firstPath/concatenated")
    }

    func test_relativeTo_baseURLHasQuery_requestHasNoQuery() {
        let request = URLRequest(url: URL(string: "concatenated")!)
        let url = request.relativeTo(URL(string: "https://google.com?param=1")!).url

        XCTAssertEqual(url?.absoluteString, "https://google.com/concatenated")
    }

    func test_relativeTo_urlHasQuery_requestHasQuery() {
        let request = URLRequest(url: URL(string: "concatenated?toKeep=1")!)
        let url = request.relativeTo(URL(string: "https://google.com?param=1")!).url

        XCTAssertEqual(url?.absoluteString, "https://google.com/concatenated?toKeep=1")
    }
}
