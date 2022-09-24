# SimpleHTTP

![swift](https://img.shields.io/badge/Swift-5.5%2B-orange?logo=swift&logoColor=white)
![platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey)
![tests](https://github.com/pjechris/SimpleHTTP/actions/workflows/test.yml/badge.svg)

[![twitter](https://img.shields.io/badge/twitter-pjechris-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/pjechris)
[![doc](https://img.shields.io/badge/read%20the%20doc-8CA1AF?logo=readthedocs&logoColor=white)](https://pjechris.github.io/SimpleHTTP/)

Make HTTP API calls easier. Built on top of URLSession.

## Installation

Use Swift Package Manager to install the library:

```swift
dependencies: [
  .package(url: "https://github.com/pjechris/SimpleHTTP", from: "0.4.0"),
]
```

The package come with 2 modules:

- `SimpleHTTP` which bring the full framework API described in this README
- `SimpleHTTPFoundation` which only bring a few addition to Foundation API. See this [article](https://swiftunwrap.com/article/designing-http-framework-foundation/) or [API doc](https://pjechris.github.io/SimpleHTTP/) to have a glimpse of what is provided.

## Basic Usage

### Building a request

You make requests by creating [`Request`](https://pjechris.github.io/SimpleHTTP/Structs/Request.html) objects. You can either create them manually or provide static definition by extending `Request`:

```swift
extension Request {
  static let func login(_ body: UserBody) -> Request<UserResponse> {
    .post("login", body: body)
  }
}
```

This defines a `Request.login(_:)` method which create a request targeting "login" endpoint by sending a `UserBody` and expecting a `UserResponse` as response.

### Sending a request

You can use your request along `URLSession` by converting it into a `URLRequest` by calling `request.toURLRequest(encoder:relativeTo:accepting)`.

You can also use a `Session` object. [`Session`](https://pjechris.github.io/SimpleHTTP/Classes/Session.html) is somewhat similar to `URLSession` but providing additional functionalities:

- encoder/decoder for all requests
- error handling
- ability to [intercept](#interceptor) requests

```swift

let session = Session(
  baseURL: URL(string: "https://github.com")!,
  encoder: JSONEncoder(),
  decoder: JSONDecoder()
)

try await session.response(for: .login(UserBody(username: "pjechris", password: "MyPassword")))

```

A few words about Session:

- `baseURL` will be prepended to all call endpoints
- You can skip encoder and decoder if you use JSON
- You can provide a custom `URLSession` instance if ever needed

## Send a body

Request support two body types:

- [Encodable](#encodable)
- [Multipart](#multipart)

### Encodable

To send an Encodable object just set it as your Request body:

```swift
struct UserBody: Encodable {}

extension Request {
  static func login(_ body: UserBody) -> Request<LoginResponse> {
    .post("login", body: body)
  }
}
```

### Multipart

You can create [multipart](https://pjechris.github.io/SimpleHTTP/Structs/MultipartFormData.html) content from two kind of content

- From a disk file (using a `URL`)
- From raw content (using `Data`)

First example show how to create a request sending an audio file as request body:

```swift
extension Request {
  static func send(audioFile: URL) throws -> Request<SendAudioResponse> {
    var multipart = MultipartFormData()

    try multipart.add(url: audioFile, name: "define_your_name")

    return .post("v1/sendAudio", body: multipart)
  }
}
```

Second example show same request but this time audio file is just some raw unknown data:

```swift
  static func send(audioFile: Data) throws -> Request<SendAudioResponse> {
    var multipart = MultipartFormData()

    try multipart.add(data: audioFile, name: "your_name", mimeType: "audioFile_mimeType")

    return .post("v1/sendAudio", body: multipart)
  }
}
```

Note you can add multiple contents inside a `MultipartFormData`. For instance here we send both a audio file and an image:

```swift
extension Request {
  static func send(audio: URL, image: Data) throws -> Request<SendAudioImageResponse> {
    var multipart = MultipartFormData()

    try multipart.add(url: audio, name: "define_your_name")
    try multipart.add(data: image, name: "your_name", mimeType: "image_mimeType")

    return .post("v1/send", body: multipart)
  }
}
```

## Constant endpoints

You can declare constant endpoints if needed (refer to Endpoint documentation to see more):

```swift
extension Endpoint {
  static let login: Endpoint = "login"
}

extension Request {
  static let func login(_ body: UserBody) -> Request<UserResponse> {
    .post(.login, body: body)
  }
}
```

## Interceptor

When using Session you can add automatic behavior to your requests/responses using `Interceptor` like authentication, logging, request retrying, etc...

### `RequestInterceptor`

[`RequestInterceptor`](https://pjechris.github.io/SimpleHTTP/Protocols/RequestInterceptor.html) allows to adapt and/or retry a request:

- `adaptRequest` method is called before making a request allowing you to transform it adding headers, changing path, ...
- `rescueRequestError` is called whenever the request fail. You'll have a chance to retry the request. This can be used to re-authenticate the user for instance

### `ResponseInterceptor`

[`ResponseInterceptor`](https://pjechris.github.io/SimpleHTTP/Protocols/ResponseInterceptor.html) is dedicated to intercept and server responses:

- `adaptResponse` change the server output
- `receivedResponse` notify about the server final response (a valid output or error)
