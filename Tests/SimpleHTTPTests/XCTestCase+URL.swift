import XCTest

extension XCTestCase {
    func url(forResource fileName: String, withExtension ext: String) throws -> URL {
        try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: ext))
    }
}
