import XCTest
import SimpleHTTP

class QueryParamTests: XCTestCase {

    func test_queryValue_multidimenstionalArray_returnFlattenCollection() {
        let array: [[Int]] = [[1, 2, 3],[4,5,6]]

        XCTAssertEqual(array.queryValue, .collection(["1", "2", "3", "4", "5", "6"]))
    }

}
