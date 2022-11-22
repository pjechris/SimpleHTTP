import Foundation

/// Protocol allowing to use a type as a query parameter
public protocol QueryParam {
    /// the parameter value
    var queryValue: QueryValue? { get }
}

/// Query parameter value
public enum QueryValue: Equatable {
    case single(String)
    case collection([String])
}

extension QueryParam where Self: RawRepresentable, RawValue: QueryParam {
    public var queryValue: QueryValue? { rawValue.queryValue }
}

extension Int: QueryParam {
    public var queryValue: QueryValue? { .single(String(self)) }
}

extension String: QueryParam {
    public var queryValue: QueryValue? { .single(self) }
}

extension Bool: QueryParam {
    public var queryValue: QueryValue? { .single(self ? "true" : "false") }
}

extension Data: QueryParam {
    public var queryValue: QueryValue? { String(data: self, encoding: .utf8).map(QueryValue.single) }
}

extension Optional: QueryParam where Wrapped: QueryParam {
    public var queryValue: QueryValue? {
        self.flatMap { $0.queryValue }
    }
}

extension Array: QueryParam where Element: QueryParam {
    public var queryValue: QueryValue? {
        let values = self
            .compactMap { $0.queryValue }
            .flatMap { queryValue -> [String] in
                switch queryValue {
                case .single(let value):
                    return [value]
                case .collection(let values):
                    return values
                }
            }

        return .collection(values)
    }
}
