# SimpleHTTP

![swift](https://img.shields.io/badge/Swift-5.5%2B-orange?logo=swift&logoColor=white)
![platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey)
![tests](https://github.com/pjechris/SimpleHTTP/actions/workflows/test.yml/badge.svg)
[![twitter](https://img.shields.io/badge/twitter-pjechris-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/pjechris)

Simple declarative HTTP API framework

## Basic Usage

### Building a request
First step is to build a request. You make requests by providing extension on top of `Request` type:

```swift
extension Request {
  static let func login(_ body: UserBody) -> Self where Output == UserResponse {
    .post("login", body: body)
  }
}
```

And... voila! We defined a `login(_:)` request which will request login endpoint by sending a `UserBody` and waiting for a `UserResponse`. Now it's time to use it.

You can declare constant endpoints if needed (refer to Endpoint documentation to see more):

```swift
extension Endpoint {
  static let login: Endpoint = "login"
}

extension Request {
  static let func login(_ body: UserBody) -> Self where Output == UserResponse {
    .post(.login, body: body)
  }
}
```

### Sending a request

To send a request use a `Session` instance. `Session` is somewhat similar to `URLSession` but providing additional functionalities.

```swift

let session = Session(baseURL: URL(string: "https://github.com")!, encoder: JSONEncoder(), decoder: JSONDecoder())

session.publisher(for: .login(UserBody(username: "pjechris", password: "MyPassword")))

```

You can now use the returned publisher however you want. Its result is similar to what you have received with `URLSession.shared.dataTaskPublisher(for: ...).decode(type: UserResponse.self, decoder: JSONDecoder())`.

A few words about Session:

- `baseURL` will be prepended to all call endpoints
- You can skip encoder and decoder if you use JSON
- You can provide a custom `URLSession` instance if ever needed

## Send a body

### Encodable

You will build your request by sending your `body`  to construct it:

```swift
struct UserBody: Encodable {}

extension Request {
  static func login(_ body: UserBody) -> Self where Output == LoginResponse {
    .post("login", body: .encodable(body))
  }
}
```

We defined a `login(_:)` request which will request login endpoint by sending a `UserBody` and waiting for a `LoginResponse`

### Multipart

You we build 2 requests:

- send `URL`
- send a `Data`

```swift
extension Request {
  static func send(audio: URL) throws -> Self where Output == SendAudioResponse {
    var multipart = MultipartFormData()
    try multipart.add(url: audio, name: "define_your_name")
    return .post("sendAudio", body: .multipart(multipart))
  }

  static func send(audio: Data) throws -> Self where Output == SendAudioResponse {
    var multipart = MultipartFormData()
    try multipart.add(data: data, name: "your_name", fileName: "your_fileName", mimeType: "right_mimeType")
    return .post("sendAudio", body: .multipart(multipart))
  }
}
```

We defined the 2  `send(audio:)` requests which will request `sendAudio` endpoint by sending an `URL` or a `Data` and waiting for a `SendAudioResponse`

We can add multiple `Data`/`URL` to the multipart

```swift
extension Request {
  static func send(audio: URL, image: Data) throws -> Self where Output == SendAudioImageResponse {
    var multipart = MultipartFormData()
    try multipart.add(url: audio, name: "define_your_name")
    try multipart.add(data: image, name: "your_name", fileName: "your_fileName", mimeType: "right_mimeType")
    return .post("sendAudioImage", body: .multipart(multipart))
  }
}
```

## Interceptor

Protocol `Interceptor` enable powerful request interceptions. This include authentication, logging, request retrying, etc...

### `RequestInterceptor`

`RequestInterceptor` allow to adapt a or retry a request whenever it failed:

- `adaptRequest` method is called before making a request and allow you to transform it adding headers, changing path, ...
- `rescueRequestError` is called whenever the request fail. You'll have a chance to retry the request. This can be used to re-authenticate the user for instance

### `ResponseInterceptor`

`ResponseInterceptor` is dedicated to intercept and server responses:

- `adaptResponse` change the server output
- `receivedResponse` notify about the server final response (a valid output or error)
