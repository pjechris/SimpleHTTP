import XCTest
@testable import SimpleHTTP

class MultipartFormDataTest: XCTestCase {

  let crlf = EncodingCharacters.crlf

  func test_addData_withoutFileNameAndMimeType_expectOneBodyPart() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)
    let data = "I'm pjechris, Nice to meet you"
    let name = "data"
    let expectedHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name)\"")
    ]

    multipart.add(data: Data(data.utf8), name: name)

    XCTAssertEqual(multipart.bodyParts.count, 1)
    let bodyPart = try XCTUnwrap(multipart.bodyParts.first)
    XCTAssertEqual(bodyPart.headers, expectedHeaders)
  }

  func test_addData_oneWithoutFileNameAndMimeType_secondWithAllValue_expect2BodyParts() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)
    let data1 = "Swift"
    let name1 = "swift"
    let data2 = "Combine"
    let name2 = "combine"
    let fileName2 = "combine.txt"
    let mimeType2 = "text/plain"
    let expectedFirstBodyPartHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name1)\"")
    ]
    let expectedLastBodyPartHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name2)\"; filename=\"\(fileName2)\""),
      Header(name: .contentType, value: mimeType2)
    ]

    multipart.add(data: Data(data1.utf8), name: name1)
    multipart.add(data: Data(data2.utf8), name: name2, fileName: fileName2, mimeType: mimeType2)

    XCTAssertEqual(multipart.bodyParts.count, 2)
    let bodyPart1 = try XCTUnwrap(multipart.bodyParts.first)
    XCTAssertEqual(bodyPart1.headers, expectedFirstBodyPartHeaders)
    let bodyPart2 = try XCTUnwrap(multipart.bodyParts.last)
    XCTAssertEqual(bodyPart2.headers, expectedLastBodyPartHeaders)
  }

  func test_addURL_bodyPart() throws {
    let boundary = "boundary"
    var multipart = MultipartFormData(boundary: boundary)
    let url = URL.Images.swift
    let name = "swift"
    let expectedHeaders: [Header] = [
      Header(name: .contentDisposition, value: "form-data; name=\"\(name)\"; filename=\"swift.png\""),
      Header(name: .contentType, value: "image/png")
    ]

    try multipart.add(url: url, name: name)

    XCTAssertEqual(multipart.bodyParts.count, 1)
    let bodyPart = try XCTUnwrap(multipart.bodyParts.first)
    XCTAssertEqual(bodyPart.headers, expectedHeaders)
  }

}
