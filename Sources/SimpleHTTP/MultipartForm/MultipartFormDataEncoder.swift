import Foundation

struct MultipartFormDataEncoder {
    let boundary: String
    private var bodyParts: [BodyPart]

    //
    // The optimal read/write buffer size in bytes for input and output streams is 1024 (1KB). For more
    // information, please refer to the following article:
    //   - https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Streams/Articles/ReadingInputStreams.html
    //
    private let streamBufferSize = 1024

    public init(body: MultipartFormData) {
        self.boundary = body.boundary
        self.bodyParts = body.bodyParts
    }

    mutating func encode() throws -> Data {
        var encoded = Data()

        if var first = bodyParts.first {
            first.hasInitialBoundary = true
            bodyParts[0] = first
        }

        if var last = bodyParts.last {
            last.hasFinalBoundary = true
            bodyParts[bodyParts.count - 1] = last
        }

        for bodyPart in bodyParts {
            encoded.append(try encodeBodyPart(bodyPart))
        }

        return encoded
    }

    private func encodeBodyPart(_ bodyPart: BodyPart) throws -> Data {
        var encoded = Data()

        if bodyPart.hasInitialBoundary {
            encoded.append(Boundary.data(for: .initial, boundary: boundary))
        } else {
            encoded.append(Boundary.data(for: .encapsulated, boundary: boundary))
        }

        encoded.append(try encodeBodyPart(headers: bodyPart.headers))
        encoded.append(try encodeBodyPart(stream: bodyPart.stream(), length: bodyPart.length))

        if bodyPart.hasFinalBoundary {
            encoded.append(Boundary.data(for: .final, boundary: boundary))
        }

        return encoded
    }

    private func encodeBodyPart(headers: [Header]) throws -> Data {
        let headerText = headers.map { "\($0.name.key): \($0.value)\(EncodingCharacters.crlf)" }
            .joined()
        + EncodingCharacters.crlf

        return Data(headerText.utf8)
    }

    private func encodeBodyPart(stream: InputStream, length: Int) throws -> Data {
        var encoded = Data()

        stream.open()
        defer { stream.close() }

        while stream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = stream.read(&buffer, maxLength: streamBufferSize)

            if let error = stream.streamError {
                throw BodyPart.Error.inputStreamReadFailed(error.localizedDescription)
            }

            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }

        guard encoded.count == length else {
            throw BodyPart.Error.unexpectedInputStreamLength(expected: length, bytesRead: encoded.count)
        }

        return encoded
    }

}

extension BodyPart {

    enum Error: Swift.Error {
        case inputStreamReadFailed(String)
        case unexpectedInputStreamLength(expected: Int, bytesRead: Int)
    }

}
