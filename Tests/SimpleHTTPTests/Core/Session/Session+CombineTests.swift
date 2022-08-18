import Foundation
import XCTest
@testable import SimpleHTTP

#if canImport(Combine)

import Combine

class SessionCombineTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
    }
    
    func test_publisher_returnOutput() {
        let output = CombineTest(value: "hello world")
        let expectation = XCTestExpectation()
        
        let session = Session(baseURL: URL(string: "/")!) { _ in
            URLDataResponse(data: try! JSONEncoder().encode(output), response: .success)
        }
        
        session.publisher(for: Request<CombineTest>.get("test"))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    expectation.fulfill()
                    XCTAssertEqual($0, output)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
}

#endif

private struct CombineTest: Codable, Equatable {
    let value: String
}
