import Foundation

public struct ContentDataCoderConfiguration {
    public var encoder: ContentDataEncoderConfiguration
    public var decoder: ContentDataDecoderConfiguration
    public let defaultType: HTTPContentType

    public init(
        default: HTTPContentType,
        encoder: ContentDataEncoderConfiguration,
        decoder: ContentDataDecoderConfiguration,
    ) {
        self.encoder = encoder
        self.decoder = decoder
        self.defaultType = `default`
    }

    public init() {
        self.init(
            default: .json,
            encoder: [
                .json: JSONEncoder(),
                .formURLEncoded: FormURLEncoder()
            ],
            decoder: [
                .json: JSONDecoder()
            ]
        )
    }
}

@dynamicMemberLookup
public struct ContentDataEncoderConfiguration: ExpressibleByDictionaryLiteral {
    private var encoders: [HTTPContentType: ContentDataEncoder]

    public init(encoders: [HTTPContentType: ContentDataEncoder]) {
        self.encoders = encoders
    }

    public init(dictionaryLiteral elements: (HTTPContentType, ContentDataEncoder)...) {
        self.init(encoders: Dictionary(uniqueKeysWithValues: elements))
    }

    public subscript(contentType: HTTPContentType) -> ContentDataEncoder? {
        get { encoders[contentType] }
        set { encoders[contentType] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<HTTPContentType.Type, HTTPContentType>) -> ContentDataEncoder? {
        get { self[HTTPContentType.self[keyPath: keyPath]] }
        set { self[HTTPContentType.self[keyPath: keyPath]] = newValue }
    }
}

@dynamicMemberLookup
public struct ContentDataDecoderConfiguration: ExpressibleByDictionaryLiteral {
    private var decoders: [HTTPContentType: ContentDataDecoder]

    public init(decoders: [HTTPContentType: ContentDataDecoder]) {
        self.decoders = decoders
    }

    public init(dictionaryLiteral elements: (HTTPContentType, ContentDataDecoder)...) {
        self.init(decoders: Dictionary(uniqueKeysWithValues: elements))
    }

    public subscript(contentType: HTTPContentType) -> ContentDataDecoder? {
        get { decoders[contentType] }
        set { decoders[contentType] = newValue }
    }

    public subscript(dynamicMember keyPath: KeyPath<HTTPContentType.Type, HTTPContentType>) -> ContentDataDecoder? {
        get { self[HTTPContentType.self[keyPath: keyPath]] }
        set { self[HTTPContentType.self[keyPath: keyPath]] = newValue }
    }
}
