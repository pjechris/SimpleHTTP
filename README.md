# SimpleHTTP

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

You can also use an enum to define your Request path:

```swift
enum MyAppEndpoint: String, Path {
  case login
}

extension Request {
  static let func login(_ body: UserBody) -> Self where Output == UserResponse {
    .post(MyAppEndpoint.login, body: body)
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
