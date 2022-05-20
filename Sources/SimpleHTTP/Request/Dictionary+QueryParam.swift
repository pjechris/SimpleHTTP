import Foundation

extension Dictionary where  Key == String, Value == QueryParam {
    var queryItems: [URLQueryItem]  {
        self.flatMap { key, value -> [URLQueryItem] in
            switch value.queryValue {
            case .single(let value):
                return [URLQueryItem(name: key, value: value)]
            case .collection(let values):
                return values.map { URLQueryItem(name: "\(key)[]", value: $0) }
            case .none:
                return []
            }
        }
    }
    
}
