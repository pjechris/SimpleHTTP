import XCTest
@testable import SimpleHTTP

class MultipartFormDataEncoderTests: XCTestCase {

    let crlf = EncodingCharacters.crlf

    func test_encode_multipartAddData_bodyPart() throws {
        // Given
        let boundary = "boundary"
        var multipart = MultipartFormData(boundary: boundary)

        let data = "I'm pjechris, Nice to meet you"
        let name = "data"
        multipart.add(data: Data(data.utf8), name: name)

        let expectedString = (
            Boundary.string(for: .initial, boundary: boundary)
            + "Content-Disposition: form-data; name=\"\(name)\"\(crlf)\(crlf)"
            + data
            + Boundary.string(for: .final, boundary: boundary)
        )
        let expectedData = Data(expectedString.utf8)

        // When
        let encodedData = try MultipartFormDataEncoder(body: multipart).encode()

        // Then
        XCTAssertEqual(encodedData, expectedData)
    }


    func test_encoding_data_multipleBodyPart() throws {
        let boundary = "boundary"
        var multipart = MultipartFormData(boundary: boundary)

        let data1 = "Swift"
        let name1 = "swift"
        multipart.add(data: Data(data1.utf8), name: name1)

        let data2 = "Combine"
        let name2 = "combine"
        let mimeType2 = "text/plain"
        multipart.add(data: Data(data2.utf8), name: name2, mimeType: mimeType2)

        let expectedString = (
            Boundary.string(for: .initial, boundary: boundary)
            + "Content-Disposition: form-data; name=\"\(name1)\"\(crlf)\(crlf)"
            + data1
            + Boundary.string(for: .encapsulated, boundary: boundary)
            + "Content-Disposition: form-data; name=\"\(name2)\"\(crlf)"
            + "Content-Type: \(mimeType2)\(crlf)\(crlf)"
            + data2
            + Boundary.string(for: .final, boundary: boundary)
        )
        let expectedData = Data(expectedString.utf8)

        let encodedData = try MultipartFormDataEncoder(body: multipart).encode()

        XCTAssertEqual(encodedData, expectedData)
    }

    func test_encoding_url_bodyPart() throws {
        let boundary = "boundary"
        var multipart = MultipartFormData(boundary: boundary)

        let url = URL.Images.swift
        let name = "swift"
        try multipart.add(url: url, name: name)

        var expectedData = Data()
        expectedData.append(Boundary.data(for: .initial, boundary: boundary))
        expectedData.append(
            Data((
                "Content-Disposition: form-data; name=\"\(name)\"; filename=\"swift.png\"\(crlf)"
                + "Content-Type: image/png\(crlf)\(crlf)"
            ).utf8)
        )
        expectedData.append(try Data(contentsOf: url))
        expectedData.append(Boundary.data(for: .final, boundary: boundary))

        let encodedData = try MultipartFormDataEncoder(body: multipart).encode()

        XCTAssertEqual(encodedData, expectedData)
    }

    func test_encoding_url_multipleBodyPart() throws {
        let boundary = "boundary"
        var multipart = MultipartFormData(boundary: boundary)

        let url1 = URL.Images.swift
        let name1 = "swift"
        try multipart.add(url: url1, name: name1)

        let url2 = URL.Images.swiftUI
        let name2 = "swiftUI"
        try multipart.add(url: url2, name: name2)

        var expectedData = Data()
        expectedData.append(Boundary.data(for: .initial, boundary: boundary))
        expectedData.append(Data((
            "Content-Disposition: form-data; name=\"\(name1)\"; filename=\"swift.png\"\(crlf)"
            + "Content-Type: image/png\(crlf)\(crlf)").utf8
        )
        )
        expectedData.append(try Data(contentsOf: url1))
        expectedData.append(Boundary.data(for: .encapsulated, boundary: boundary))
        expectedData.append(
            Data((
                "Content-Disposition: form-data; name=\"\(name2)\"; filename=\"swiftUI.png\"\(crlf)"
                + "Content-Type: image/png\(crlf)\(crlf)"
            ).utf8)
        )
        expectedData.append(try Data(contentsOf: url2))
        expectedData.append(Boundary.data(for: .final, boundary: boundary))

        let encodedData = try MultipartFormDataEncoder(body: multipart).encode()

        XCTAssertEqual(encodedData, expectedData)
    }

    func test_encoding_varryingType_multipleBodyPart() throws {
        let boundary = "boundary"
        var multipart = MultipartFormData(boundary: boundary)

        let data = "I'm pjechris, Nice to meet you"
        let name1 = "data"
        multipart.add(data: Data(data.utf8), name: name1)

        let url = try url(forResource: "swift", withExtension: "png")
        let name2 = "swift"
        try multipart.add(url: url, name: name2)

        var expectedData = Data()
        expectedData.append(Boundary.data(for: .initial, boundary: boundary))
        expectedData.append(
            Data((
                "Content-Disposition: form-data; name=\"\(name1)\"\(crlf)\(crlf)"
                + data
            ).utf8)
        )
        expectedData.append(Boundary.data(for: .encapsulated, boundary: boundary))
        expectedData.append(
            Data((
                "Content-Disposition: form-data; name=\"\(name2)\"; filename=\"swift.png\"\(crlf)"
                + "Content-Type: image/png\(crlf)\(crlf)"
            ).utf8)
        )
        expectedData.append(try Data(contentsOf: url))
        expectedData.append(Boundary.data(for: .final, boundary: boundary))

        let encodedData = try MultipartFormDataEncoder(body: multipart).encode()

        XCTAssertEqual(encodedData, expectedData)
    }


}
