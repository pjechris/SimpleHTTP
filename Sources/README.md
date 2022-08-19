# Packages

The project is split in two packages:

- SimpleHTTPFoundation
- SimpleFoundation

## SimpleHTTPFoundation

This package contain extensions on Foundation objects to bring some convenience methods to Foundation that could be used by any network package or project.

Related article: [Designing a lightweight HTTP framework: foundation](https://swiftunwrap.com/article/designing-http-framework-foundation/).

## SimpleHTTP

It contain package true functionalities like Request or Session objects. When building a functionality in this package try to do it in 3 steps:

- Design the new objects
- Make them interact with Foundation. For instance `Request+URLRequest.swift` bridge from `Request` to `URLRequest`
- Add pieces to `Session`
