import XCTest
import SimpleHTTP

class CompositeInterceptorTests: XCTestCase {
    func test_shouldRescue_moreThanOneInterceptorRescue_callFirstOneOnly() async throws {
        let interceptors: CompositeInterceptor = [
            InterceptorStub(shouldRequestMock: { _ in false }),
            InterceptorStub(shouldRequestMock: { _ in true }),
            InterceptorStub(shouldRequestMock: { _ in
                XCTFail("should not be called because request was already rescued")
                return true
            })
        ]

        let result = try await interceptors
            .shouldRescueRequest(Request<Void>.get("/test"), error: HTTPError(statusCode: 888))

        XCTAssertTrue(result)
    }
}

private struct InterceptorStub: Interceptor {
    var shouldRequestMock: (Error) throws -> Bool = { _ in false }

    func shouldRescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool {
        try shouldRequestMock(error)
    }

    func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
        request
    }

    func adaptOutput<Output>(_ output: Output, for request: Request<Output>) throws -> Output {
        output
    }

    func receivedResponse<Output>(_ result: Result<Output, Error>, for request: Request<Output>) {

    }

}