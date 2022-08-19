import Foundation

/// A Type representing a URL path
public protocol Path {
  var path: String { get }
}

extension Path where Self: RawRepresentable, RawValue == String {
  public var path: String { rawValue }
}

extension String: Path {
  public var path: String { self }
}
