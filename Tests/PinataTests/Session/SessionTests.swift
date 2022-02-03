import XCTest
import Combine
import Pinata

class SessionTests: XCTestCase {
    let baseURL = URL(string: "https://sessionTests.io")!
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
    }
    
    func test_publisherFor_responseIsValid_decodedOutputIsReturned() throws {
        let response = Content(value: "response")
        let session = sesssionStub()  { (data: try! JSONEncoder().encode(response), response: .success) }
        let expectation = XCTestExpectation()
        
        session.publisher(for: Request.test())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    XCTAssertEqual($0, response)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_publisherFor_responseIsValid_adaptResponseThrow_itReturnAnError() {
        let output = Content(value: "adapt throw")
        let interceptor = InterceptorStub()
        let session = sesssionStub(
            interceptor: [interceptor],
            data: { (data: try! JSONEncoder().encode(output), response: .success) }
        )
        let expectation = XCTestExpectation()
        
        interceptor.adaptResponseMock = { _, _ in
            throw CustomError()
        }
        
        session.publisher(for: .test())
            .sink(
                receiveCompletion: {
                    if case let .failure(error) = $0 {
                        XCTAssertEqual(error as? CustomError, CustomError())
                    }
                    else {
                        XCTFail()
                    }
                    
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_publisherFor_rescue_rescueIsSuccess_itRetryRequest() {
        var isRescued = false
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            (data: Data(), response: isRescued ? .success : .unauthorized)
        }
        let expectation = XCTestExpectation()
        
        interceptor.rescueRequestErrorMock = { _ in
            isRescued.toggle()
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        
        session.publisher(for: .void())
            .sink(
                receiveCompletion: {
                    XCTAssertTrue(isRescued)
                    
                    if case .failure = $0 {
                        XCTFail("retried request final result should be success")
                    }
                    
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_publisherFor_outputIsDecoded_itCallInterceptorReceivedResponse() {
        let output = Content(value: "hello")
        let interceptor = InterceptorStub()
        let session = sesssionStub(interceptor: [interceptor]) {
            (data: try! JSONEncoder().encode(output), response: .success)
        }
        let expectation = XCTestExpectation()
        
        interceptor.receivedResponseMock = { response, _ in
            let response = response as? Result<Content, Error>
            
            XCTAssertEqual(try? response?.get(), output)
            expectation.fulfill()
        }
        
        session.publisher(for: .test())
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    /// helper to create a session for testing
    private func sesssionStub(interceptor: CompositeInterceptor = [], data: @escaping () -> Session.RequestData)
    -> Session {
        let config = SessionConfiguration(encoder: encoder, decoder: decoder, interceptors: interceptor)
        
        return Session(baseURL: baseURL, configuration: config, dataPublisher: { _ in
            Just(data())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        })
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
    var rescueRequestErrorMock: ((Error) -> AnyPublisher<Void, Error>?)?
    var receivedResponseMock: ((Any, Any) -> ())?
    var adaptResponseMock: ((Any, Any) throws -> Any)?
    
    func adaptRequest<Output>(_ request: Request<Output>) -> Request<Output> {
        request
    }
    
    func rescueRequest<Output>(_ request: Request<Output>, error: Error) -> AnyPublisher<Void, Error>? {
        rescueRequestErrorMock?(error)
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
