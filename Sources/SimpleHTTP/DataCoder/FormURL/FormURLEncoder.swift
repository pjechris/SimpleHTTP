import Foundation

public struct FormURLEncoder: ContentDataEncoder {
    public static let contentType: HTTPContentType = .formURLEncoded

    public init() { }

    public func encode(_ value: some Encodable) throws -> Data {
        let encoder = FormKeyValueEncoder()
        try value.encode(to: encoder)

        let encoded = encoder.pairs
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")

        guard let data = encoded.data(using: .utf8) else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "UTF-8 encoding failed"))
        }

        return data
    }
}

// MARK: - Encoder

private final class FormKeyValueEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var pairs: [(key: String, value: String)] = []

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(FormKeyedContainer(encoder: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Form URL encoding does not support unkeyed containers")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Form URL encoding does not support single value containers")
    }
}

// MARK: - Keyed container

private struct FormKeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: FormKeyValueEncoder
    var codingPath: [CodingKey] = []

    mutating func encodeNil(forKey key: Key) throws {}

    mutating func encode(_ value: String, forKey key: Key) throws {
        append(key, value)
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        append(key, "\(value)")
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        append(key, "\(value)")
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        append(key, "\(value)")
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        append(key, "\(value)")
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        fatalError("Nested containers not supported")
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Nested containers not supported")
    }

    mutating func superEncoder() -> Encoder { encoder }
    mutating func superEncoder(forKey key: Key) -> Encoder { encoder }

    private func append(_ key: Key, _ value: String) {
        encoder.pairs.append((key: key.stringValue, value: value))
    }
}
