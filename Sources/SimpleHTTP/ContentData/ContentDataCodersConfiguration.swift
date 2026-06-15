import Foundation

public typealias ContentDataEncodersConfiguration = [HTTPContentType: ContentDataEncoder]
public typealias ContentDataDecodersConfiguration = [HTTPContentType: ContentDataDecoder]

/// Defines the list of encoders and decoders to use.
public struct ContentDataCodersConfiguration {
    public var encoders: ContentDataEncodersConfiguration
    public var decoders: ContentDataDecodersConfiguration
    public let defaultType: HTTPContentType

    public init(
        default: HTTPContentType,
        encoders: ContentDataEncodersConfiguration,
        decoders: ContentDataDecodersConfiguration,
    ) {
        self.encoders = encoders
        self.decoders = decoders
        self.defaultType = `default`
    }

    /// Creates a configuration with default coders and decoders.
    ///
    /// - Note: default encoder/decoder is set to JSON
    public init() {
        self.init(
            default: .json,
            encoders: [
                .json: JSONEncoder(),
                .formURLEncoded: FormURLEncoder()
            ],
            decoders: [
                .json: JSONDecoder()
            ]
        )
    }
}

extension ContentDataCodersConfiguration {
    /// defines a single encoder to use for encoding `contentType` requests. If an encoder was already defined it will be replaced with the new value
    public func encoding(_ contentType: HTTPContentType, with encoder: ContentDataEncoder) -> Self {
        var copy = self
        copy.encoders[contentType] = encoder
        return copy
    }

    /// defines a single decoder for decoding `contentType` responses.  If a decoder was already defined it will be replaced with the new value
    public func decoding(_ contentType: HTTPContentType, with decoder: ContentDataDecoder) -> Self {
        var copy = self
        copy.decoders[contentType] = decoder
        return copy
    }
}
