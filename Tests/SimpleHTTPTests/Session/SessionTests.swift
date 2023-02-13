import XCTest
import Combine
@testable import SimpleHTTP

class SessionAsyncTests: XCTestCase {
    let baseURL = URL(string: "https://sessionTests.io")!
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func test_response_responseIsValid_decodedOutputIsReturned() async throws {
        let expectedResponse = Content(value: "response")
        let session = sesssionStub {
            URLDataResponse(data: try! JSONEncoder().encode(expectedResponse), response: .success)
        }
        let response = try await session.response(for: Request.test())

        XCTAssertEqual(response, expectedResponse)
    }

    func test_response_responseIsValid_adaptResponseThrow_itReturnAnError() async {
        let output = Content(value: "adapt throw")
        let interceptor = InterceptorStub()
        let session = sesssionStub(
            interceptor: [interceptor],
            data: { URLDataResponse(data: try! JSONEncoder().encode(output), response: .success) }
        )

        interceptor.adaptResponseMock = { _, _ in
            throw CustomError()
        }

        do {
            _ = try await session.response(for: .test())
            XCTFail()
        }
        catch {
            XCTAssertEqual(error as? CustomError, CustomError())
        }
    }

    func test_response_rescue_rescueIsSuccess_itRetryRequest() async throws {
        var isRescued = false
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            URLDataResponse(data: Data(), response: isRescued ? .success : .unauthorized)
        }

        interceptor.rescueRequestErrorMock = { _ in
            isRescued.toggle()
            return true
        }

        _ = try await session.response(for: .void())

        XCTAssertTrue(isRescued)
    }

    func test_response_outputIsDecoded_itCallInterceptorReceivedResponse() async throws {
        let output = Content(value: "hello")
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            URLDataResponse(data: try! JSONEncoder().encode(output), response: .success)
        }

        interceptor.receivedResponseMock = { response, _ in
            let response = response as? Result<Content, Error>

            XCTAssertEqual(try? response?.get(), output)
        }

        _ = try await session.response(for: .test())
    }

    func test_response_httpDataHasCustomError_returnCustomError() async throws {
        let session = Session(
            baseURL: baseURL,
            configuration: SessionConfiguration(encoder: encoder, decoder: decoder, dataError: CustomError.self),
            dataTask: { _ in
                URLDataResponse(data: try! JSONEncoder().encode(CustomError()), response: .unauthorized)
            })

        do {
            _ = try await session.response(for: .test())
            XCTFail()
        }
        catch {
            XCTAssertEqual(error as? CustomError, CustomError())
        }
    }

    /// helper to create a session for testing
    private func sesssionStub(interceptor: CompositeInterceptor = [], data: @escaping () throws -> URLDataResponse)
    -> Session {
        let config = SessionConfiguration(encoder: encoder, decoder: decoder, interceptors: interceptor)

        return Session(baseURL: baseURL, configuration: config, dataTask: { _ in try data() })
    }
}

private extension Path {
    static let test: Path = "test"
}

private struct Content: Codable, Equatable {
    let value: String
}

private struct CustomError: Error, Codable, Equatable {

}

private extension Request {
    static func test() -> Self where Output == Content {
        .get(.test)
    }

    static func void() -> Self where Output == Void {
        .get(.test)
    }
}

private class InterceptorStub: Interceptor {
    var rescueRequestErrorMock: (Error) throws -> Bool = { _ in false }
    var receivedResponseMock: ((Any, Any) -> Void)?
    var adaptResponseMock: ((Any, Any) throws -> Any)?

    func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
        request
    }

    func shouldRescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool {
        try rescueRequestErrorMock(error)
    }

    func adaptOutput<Output>(_ output: Output, for request: Request<Output>) throws -> Output {
        guard let mock = adaptResponseMock else {
            return output
        }

        return try mock(output, request) as! Output
    }

    func receivedResponse<Output>(_ result: Result<Output, Error>, for request: Request<Output>) {
        receivedResponseMock?(result, request)
    }
}
