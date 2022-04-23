import XCTest
import SimpleHTTP
import Combine

class AsyncSessionTests: XCTestCase {
    let baseURL = URL(string: "https://sessionTests.io")!
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func test_publisherFor_responseIsValid_decodedOutputIsReturned() async throws {
        let expectedResponse = Content(value: "response")
        let session = sesssionStub()  { (data: try! JSONEncoder().encode(expectedResponse), response: .success) }
        let response = try await session.response(for: Request.test())
        
        XCTAssertEqual(response, expectedResponse)
    }
    
    func test_publisherFor_responseIsValid_adaptResponseThrow_itReturnAnError() async {
        let output = Content(value: "adapt throw")
        let interceptor = InterceptorStub()
        let session = sesssionStub(
            interceptor: [interceptor],
            data: { (data: try! JSONEncoder().encode(output), response: .success) }
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
    
    func test_publisherFor_rescue_rescueIsSuccess_itRetryRequest() async throws {
        var isRescued = false
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            (data: Data(), response: isRescued ? .success : .unauthorized)
        }
        
        interceptor.rescueRequestErrorMock = { _ in
            isRescued.toggle()
            return true
        }
        
        _ = try await session.response(for: .void())
        
        XCTAssertTrue(isRescued)
    }
    
    func test_publisherFor_outputIsDecoded_itCallInterceptorReceivedResponse() async throws {
        let output = Content(value: "hello")
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            (data: try! JSONEncoder().encode(output), response: .success)
        }
        
        interceptor.receivedResponseMock = { response, _ in
            let response = response as? Result<Content, Error>
            
            XCTAssertEqual(try? response?.get(), output)
        }
        
        _ = try await session.response(for: .test())
    }
    
    /// helper to create a session for testing
    private func sesssionStub(interceptor: CompositeInterceptor = [], data: @escaping () -> AsyncSession.DataResponse)
    -> AsyncSession {
        let config = SessionConfiguration(encoder: encoder, decoder: decoder, interceptors: interceptor)
        
        return AsyncSession(baseURL: baseURL, configuration: config) { _ in
            data()
        }
    }
}

private enum Endpoint: String, Path {
    case test
}

private struct Content: Codable, Equatable {
    let value: String
}

private struct CustomError: Error, Equatable {
    
}

private extension Request {
    static func test() -> Self where Output == Content {
        .get(Endpoint.test)
    }
    
    static func void() -> Self where Output == Void {
        .get(Endpoint.test)
    }
}

private class InterceptorStub: Interceptor {
    var rescueRequestErrorMock: ((Error) -> Bool)?
    var receivedResponseMock: ((Any, Any) -> ())?
    var adaptResponseMock: ((Any, Any) throws -> Any)?
    
    func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
        request
    }
    
    func rescueRequest<Output>(_ request: Request<Output>, error: Error) -> AnyPublisher<Void, Error>? {
        nil
    }
    
    func rescueRequest<Output>(_ request: Request<Output>, error: Error) async throws -> Bool {
        rescueRequestErrorMock?(error) ?? false
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

