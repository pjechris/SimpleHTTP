import XCTest

extension URL {

    static func fromBundle(fileName: String, withExtension ext: String) -> URL? {
        Bundle.module.url(forResource: fileName, withExtension: ext)
    }

}

// MARK: - Foundation.Bundle

#if XCODE_BUILD
extension Foundation.Bundle {

    /// Returns resource bundle as a `Bundle`.
    /// Requires Xcode copy phase to locate files into `ExecutableName.bundle`;
    /// or `ExecutableNameTests.bundle` for test resources
    ///
    /// Solution found here
    ///  - https://stackoverflow.com/questions/47177036/use-resources-in-unit-tests-with-swift-package-manager?answertab=votes#tab-top
    static var module: Bundle = {
        var thisModuleName = "SimpleHttp"
        var url = Bundle.main.bundleURL

        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            url = bundle.bundleURL.deletingLastPathComponent()
            thisModuleName = thisModuleName.appending("Tests")
        }

        url = url.appendingPathComponent("\(thisModuleName).bundle")

        guard let bundle = Bundle(url: url) else {
            fatalError("Foundation.Bundle.module could not load resource bundle: \(url.path)")
        }

        return bundle
    }()

}
#endif
