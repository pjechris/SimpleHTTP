import Foundation

struct MultipartFormDataEncoder {
    let boundary: String
    private let bodyParts: [BodyPart]

    public init(body: MultipartFormData) {
        self.boundary = body.boundary
        self.bodyParts = body.bodyParts
    }

    func encode() throws -> Data {
        var encoded = Data()

        for (index, bodyPart) in bodyParts.enumerated() {
            encoded.append(Boundary.data(for: index == 0 ? .initial : .encapsulated, boundary: boundary))
            encoded.append(encodeBodyPart(headers: bodyPart.headers))
            encoded.append(try encodeBodyPart(content: bodyPart.content))
        }

        if !bodyParts.isEmpty {
            encoded.append(Boundary.data(for: .final, boundary: boundary))
        }

        return encoded
    }

    private func encodeBodyPart(headers: [Header]) -> Data {
        let headerText = headers.map { "\($0.name.key): \($0.value)\(EncodingCharacters.crlf)" }
            .joined()
        + EncodingCharacters.crlf

        return Data(headerText.utf8)
    }

    private func encodeBodyPart(content: BodyPart.Content) throws -> Data {
        switch content {
        case .data(let data):
            return data
        case .file(let url):
            return try Data(contentsOf: url)
        }
    }

}
