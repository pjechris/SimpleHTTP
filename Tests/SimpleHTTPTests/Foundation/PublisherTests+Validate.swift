import XCTest
import Combine
import SimpleHTTP

class PublisherValidateTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables = []
    }
    
    func test_validate_responseIsError_dataIsEmpty_converterIsNotCalled() throws {
        let output: URLSession.DataTaskPublisher.Output = (data: Data(), response: HTTPURLResponse.notFound)
        let transformer: DataErrorConverter = { _ in
            XCTFail("transformer should not be called when data is empty")
            throw NSError()
        }
        
        Just(output)
            .validate(transformer)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func test_validate_responseIsError_dataIsNotEmpty_returnCustomError() throws {
        let customError = CustomError(code: 22, message: "custom message")
        let output: URLSession.DataTaskPublisher.Output = (
            data: try JSONEncoder().encode(customError),
            response: HTTPURLResponse.notFound
        )
        let transformer: DataErrorConverter = { data in
            return try JSONDecoder().decode(CustomError.self, from: data)
        }
        
        Just(output)
            .validate(transformer)
            .sink(
                receiveCompletion: {
                    guard case let .failure(error) = $0 else {
                        return XCTFail()
                    }
                    
                    XCTAssertEqual(error as? CustomError, customError)
                },
                receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

private struct CustomError: Error, Equatable, Codable {
    let code: Int
    let message: String
}
