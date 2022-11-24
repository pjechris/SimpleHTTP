import Foundation

extension URL {

    enum Images {
        static let swift = URL.fromBundle(fileName: "swift", withExtension: "png")!
        static let swiftUI = URL.fromBundle(fileName: "swiftUI", withExtension: "png")!
    }

}
