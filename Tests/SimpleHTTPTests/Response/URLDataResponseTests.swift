import XCTest
@testable import SimpleHTTP

class URLDataResponseTests: XCTestCase {

    func test_validate_responseIsError_dataIsEmpty_converterIsNotCalled() throws {
        let response = URLDataResponse(data: Data(), response: HTTPURLResponse.notFound)
        let transformer: DataErrorDecoder = { _ in
            XCTFail("transformer should not be called when data is empty")
            throw NSError(domain: "test", code: 0)
        }

        XCTAssertThrowsError(try response.validate(errorDecoder: transformer))
    }

    func test_validate_responseIsError_dataIsNotEmpty_returnCustomError() throws {
        let customError = CustomError(code: 22, message: "custom message")
        let response = URLDataResponse(
            data: try JSONEncoder().encode(customError),
            response: HTTPURLResponse.notFound
        )
        let transformer: DataErrorDecoder = { data in
            return try JSONDecoder().decode(CustomError.self, from: data)
        }

        XCTAssertThrowsError(try response.validate(errorDecoder: transformer)) {
            XCTAssertEqual($0 as? CustomError, customError)
        }
    }
}

private struct CustomError: Error, Equatable, Codable {
    let code: Int
    let message: String
}
