import Testing
import Foundation
import SimpleHTTP

struct FormURLEncoderTests {
    let encoder = FormURLEncoder()

    struct Encode {
        let encoder = FormURLEncoder()

        @Test("single string field returns key=value pair")
        func singleStringField_returnsKeyValuePair() throws {
            let input = SingleField(name: "John")

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "name=John")
        }

        @Test("multiple fields returns ampersand-separated pairs")
        func multipleFields_returnsAmpersandSeparatedPairs() throws {
            let input = MultipleFields(name: "John", age: 30)

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "name=John&age=30")
        }

        @Test("boolean field returns true or false")
        func booleanField_returnsTrueOrFalse() throws {
            let input = BoolField(active: true)

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "active=true")
        }

        @Test("double field returns decimal value")
        func doubleField_returnsDecimalValue() throws {
            let input = DoubleField(score: 9.5)

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "score=9.5")
        }

        @Test("spaces in value are percent-encoded")
        func spacesInValue_arePercentEncoded() throws {
            let input = SingleField(name: "John Doe")

            let data = try encoder.encode(input)
            let result = String(data: data, encoding: .utf8)

            #expect(result == "name=John%20Doe")
        }

        @Test("special characters in key are percent-encoded")
        func specialCharactersInKey_arePercentEncoded() throws {
            let input = SpecialKeyField(value: "hello")

            let data = try encoder.encode(input)
            let result = String(data: data, encoding: .utf8)

            #expect(result?.contains("my%20key=hello") == true)
        }

        @Test("nil optional field is omitted")
        func nilOptionalField_isOmitted() throws {
            let input = OptionalField(name: "John", nickname: nil)

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "name=John")
        }

        @Test("present optional field is included")
        func presentOptionalField_isIncluded() throws {
            let input = OptionalField(name: "John", nickname: "JD")

            let data = try encoder.encode(input)

            #expect(String(data: data, encoding: .utf8) == "name=John&nickname=JD")
        }

        @Test("content type is form URL encoded")
        func contentType_returnsFormURLEncoded() {
            #expect(FormURLEncoder.contentType == .formURLEncoded)
        }
    }
}

// MARK: - Fixtures

private struct SingleField: Encodable {
    let name: String
}

private struct MultipleFields: Encodable {
    let name: String
    let age: Int
}

private struct BoolField: Encodable {
    let active: Bool
}

private struct DoubleField: Encodable {
    let score: Double
}

private struct OptionalField: Encodable {
    let name: String
    let nickname: String?
}

private struct SpecialKeyField: Encodable {
    enum CodingKeys: String, CodingKey {
        case value = "my key"
    }

    let value: String
}
