# Jolt

[![Language: Swift 5](https://img.shields.io/badge/language-swift5-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 14+](https://img.shields.io/badge/platform-iOS%2013%2B-blue.svg?style=flat)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/ws/blob/master/LICENSE)
[![Build Status](https://app.bitrise.io/app/a6d157138f9ee86d/status.svg?token=W7-x9K5U976xiFrI8XqcJw&branch=master)](https://app.bitrise.io/app/a6d157138f9ee86d)
[![codebeat badge](https://codebeat.co/badges/ae5feb24-529d-49fe-9e28-75dfa9e3c35d)](https://codebeat.co/projects/github-com-freshos-networking-master)

Jolt brings together `URLSession`, `Combine`, `Decodable` and `Generics` to
make connecting to a JSON api a breeze.

```swift
struct Api: NetworkingService {

    let network = JoltNetwork(baseURL: "https://jsonplaceholder.typicode.com")

    func fetchPost() -> AnyPublisher<Post, Error> {
        get("/posts/1")
    }
}
```
Later...

```swift
let api = Api()
api.fetchPost().sink(receiveCompletion: { _ in }) { post in
    // Get back some post \o/
}.store(in: &cancellables)
```

## How
By providing a lightweight client that **automates boilerplate code everyone has to write**.  
By exposing a **delightfully simple** api to get the job done simply, clearly, quickly.  
Getting swift models from a JSON api is now *a problem of the past*

URLSession + Combine + Generics + Protocols = Jolt.

## What
- [x] Build a concise Api
- [x] Automatically map your models
- [x] Uses latest Apple's [Combine](https://developer.apple.com/documentation/combine)
- [x] Compatible with native `Codable`
- [x] Embarks a built-in network logger
- [x] Pure Swift, simple, lightweight & 0 dependencies

## Getting Started

* [Install it](#install-it)
* [Create a Client](#create-a-client)
* [Changing request headers](#changing-request-headers)
* [Authenticating](#authenticating)
    * [HTTP basic](#http-basic)
    * [Bearer token](#bearer-token)
    * [Custom authentication header](#custom-authentication-header)
* [Make your first call](#make-your-first-call)
* [Get the type you want back](#get-the-type-you-want-back)
* [Pass params](#pass-params)
* [Choosing a content or parameter type](#choosing-a-content-or-parameter-type)
    * [JSON](#json)
    * [URL-encoding](#url-encoding)
    * [Multipart](#multipart)
    * [Others](#others)
<!--* [Upload multipart data](#upload-multipart-data)-->
<!--* [Add Headers](#add-headers)-->
<!--* [Add Timeout](#add-timeout)-->
* [Cancel a request](#cancel-a-request)
* [Log Network calls](#log-network-calls)
* [Handling errors](#handling-errors)
* [Support Decodable parsing](#support-decodable-parsing)
* [Design a clean api](#design-a-clean-api)

### Install it
`Jolt` is installed via the official [Swift Package Manager](https://swift.org/package-manager/).  

Select `Xcode`>`File`> `Swift Packages`>`Add Package Dependency...`  
and add `https://github.com/lukacs-m/Jolt`.

### Create a Client

Initializing an instance of **Jolt** means you have to select a [NSURLSessionConfiguration](https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration). The available types are `Default`, `Ephemeral` and `Background`, if you don't provide any or don't have special needs then `Default` will be used.

 - `Default`: The default session configuration uses a persistent disk-based cache (except when the result is downloaded to a file) and stores credentials in the user’s keychain. It also stores cookies (by default) in the same shared cookie store as the `NSURLConnection` and `NSURLDownload` classes.

- `Ephemeral`: An ephemeral session configuration object is similar to a default session configuration object except that the corresponding session object does not store caches, credential stores, or any session-related data to disk. Instead, session-related data is stored in RAM. The only time an ephemeral session writes data to disk is when you tell it to write the contents of a URL to a file. The main advantage to using ephemeral sessions is privacy. By not writing potentially sensitive data to disk, you make it less likely that the data will be intercepted and used later. For this reason, ephemeral sessions are ideal for private browsing modes in web browsers and other similar situations.

- `Background`: This configuration type is suitable for transferring data files while the app runs in the background. A session configured with this object hands control of the transfers over to the system, which handles the transfers in a separate process. In iOS, this configuration makes it possible for transfers to continue even when the app itself is suspended or terminated.

```swift
// Default
let client = JoltNetwork(baseURL: "http://httpbin.org")

// Ephemeral
let configurationFile: JoltNetworkConfigurationInitialising = JoltNetworkConfigurationInitializer(timeout: 10,
                logger: JoltLogging(),
                sessionConfiguration: .ephemeral)
let client = JoltNetwork(baseURL: "http://httpbin.org", configuration: configurationFile)
```

## Changing request headers

You can set the `header Fields` in any JoltClient object.

This will append (if not found) or overwrite (if found) what NSURLSession sends on each request.

```swift
clien.setSessionHeader(with: ["User-Agent": "your new user agent"])
```

Add header fields 

```swift
clien.addParamInSessionHeader(with: ["User-Agent": "your new user agent"])
```

## Authenticating

### HTTP basic

To authenticate using [basic authentication](http://www.w3.org/Protocols/HTTP/1.0/spec.html#BasicAA) with a username **"aladdin"** and password **"opensesame"** you only need to do this:

```swift
client.setAuthorizationHeader(username: "aladdin", password: "opensesame")
client.get("/basic-auth/aladdin/opensesame") { result in
    // Successfully authenticated!
}
```

### Bearer token

To authenticate using a [bearer token](https://tools.ietf.org/html/rfc6750) **"AAAFFAAAA3DAAAAAA"** you only need to do this:

```swift
client.setAuthorizationHeader(token: "AAAFFAAAA3DAAAAAA")
client.get("/get") { result in
    // Successfully authenticated!
}
```

### Custom authentication header

To authenticate using a custom authentication header, for example **"Token token=AAAFFAAAA3DAAAAAA"** you would need to set the following header field: `Authorization: Token token=AAAFFAAAA3DAAAAAA`. Luckily, **Networking** provides a simple way to do this:

```swift
client.setAuthorizationHeader(headerValue: "Token token=AAAFFAAAA3DAAAAAA")
client.get("/get") { result in
    // Successfully authenticated!
}
```

Providing the following authentication header `Anonymous-Token: AAAFFAAAA3DAAAAAA` is also possible:

```swift
client.setAuthorizationHeader(headerKey: "Anonymous-Token", headerValue: "AAAFFAAAA3DAAAAAA")
client.get("/get") { result in
    // Successfully authenticated!
}
```

### Make your first call
Use `get`, `post`, `put` & `delete` methods on the client to make calls.
```swift
client.get("/posts/1").sink(receiveCompletion: { _ in }) { (data:Data) in
    // data
}.store(in: &cancellables)
```

### Get the type you want back
`Networking` recognizes the type you want back via type inference.
Types supported are `Void`, `Data`, `Any`(JSON), `Decodable models`  

This enables keeping a simple api while supporting many types :
```swift
let voidPublisher: AnyPublisher<Void, Error> = client.get("")
let dataPublisher: AnyPublisher<Data, Error> = client.get("")
let jsonPublisher: AnyPublisher<Any, Error> = client.get("")
let postPublisher: AnyPublisher<Post, Error> = client.get("")
let postsPublisher: AnyPublisher<[Post], Error> = client.get("")
```

### Pass parameters
Simply pass a `[String: Any]` dictionary to the `parameters` parameter.
```swift
client.postsPublisher("/posts/1", parameters: ["optin" : true ])
    .sink(receiveCompletion: { _ in }) { (data:Data) in
      //  response
    }.store(in: &cancellables)
```

## Choosing a Content or Parameter Type

The `Content-Type` HTTP specification is so unfriendly, you have to know the specifics of it before understanding that content type is really just the parameter type. Because of this **Networking** uses a `ParameterType` instead of a `ContentType`. Anyway, here's hoping this makes it more human friendly.

### JSON

**Networking** by default uses `application/json` as the `Content-Type`, if you're sending JSON you don't have to do anything. But if you want to send other types of parameters you can do it by providing the `ParameterType` attribute.

When sending JSON your parameters will be serialized to data using `NSJSONSerialization`.

```swift
let networking = Networking(baseURL: "http://httpbin.org")
networking.post("/post", parameters: ["name" : "jameson"]) { result in
   // Successfull post using `application/json` as `Content-Type`
}
```

### URL-encoding

 If you want to use `application/x-www-form-urlencoded` just use the `.formURLEncoded` parameter type, internally **Networking** will format your parameters so they use [`Percent-encoding` or `URL-enconding`](https://en.wikipedia.org/wiki/Percent-encoding#The_application.2Fx-www-form-urlencoded_type).

```swift
let networking = Networking(baseURL: "http://httpbin.org")
networking.post("/post", parameterType: .formURLEncoded, parameters: ["name" : "jameson"]) { result in
   // Successfull post using `application/x-www-form-urlencoded` as `Content-Type`
}
```

### Multipart

**Networking** provides a simple model to use `multipart/form-data`. A multipart request consists in appending one or several [FormDataPart](https://github.com/3lvis/Networking/blob/master/Sources/FormDataPart.swift) items to a request. The simplest multipart request would look like this.

```swift
let networking = Networking(baseURL: "https://example.com")
let imageData = UIImagePNGRepresentation(imageToUpload)!
let part = FormDataPart(data: imageData, parameterName: "file", filename: "selfie.png")
networking.post("/image/upload", part: part) { result in
  // Successfull upload using `multipart/form-data` as `Content-Type`
}
```

If you need to use several parts or append other parameters than aren't files, you can do it like this:

```swift
let networking = Networking(baseURL: "https://example.com")
let part1 = FormDataPart(data: imageData1, parameterName: "file1", filename: "selfie1.png")
let part2 = FormDataPart(data: imageData2, parameterName: "file2", filename: "selfie2.png")
let parameters = ["username" : "3lvis"]
networking.post("/image/upload", parts: [part1, part2], parameters: parameters) { result in
    // Do something
}
```

**FormDataPart Content-Type**:

`FormDataPart` uses `FormDataPartType` to generate the `Content-Type` for each part. The default `FormDataPartType` is `.Data` which adds the `application/octet-stream` to your part. If you want to use a `Content-Type` that is not available between the existing `FormDataPartType`s, you can use `.Custom("your-content-type)`.

### Others

At the moment **Networking** supports four types of `ParameterType`s out of the box: `JSON`, `FormURLEncoded`, `MultipartFormData` and `Custom`. Meanwhile `JSON` and `FormURLEncoded` serialize your parameters in some way, `Custom(String)` sends your parameters as plain `NSData` and sets the value inside `Custom` as the `Content-Type`.

For example:
```swift
let networking = Networking(baseURL: "http://httpbin.org")
networking.post("/upload", parameterType: .Custom("application/octet-stream"), parameters: imageData) { result in
   // Successfull upload using `application/octet-stream` as `Content-Type`
}
```

<!---->
<!--### Upload multipart data-->
<!--For multipart calls (post/put), just pass a `MultipartData` struct to the `multipartData` parameter.-->
<!--```swift-->
<!--let params: [String: CustomStringConvertible] = [ "type_resource_id": 1, "title": photo.title]-->
<!--let multipartData = MultipartData(name: "file",-->
<!--                                  fileData: photo.data,-->
<!--                                  fileName: "photo.jpg",-->
<!--                                   mimeType: "image/jpeg")-->
<!--client.post("/photos/upload",-->
<!--            params: params,-->
<!--            multipartData: multipartData).sink(receiveCompletion: { _ in }) { (data:Data?, progress: Progress) in-->
<!--                if let data = data {-->
<!--                    print("upload is complete : \(data)")-->
<!--                } else {-->
<!--                    print("progress: \(progress)")-->
<!--                }-->
<!--}.store(in: &cancellables)-->
<!--```-->
<!---->
<!--### Add Headers-->
<!--Headers are added via the `headers` property on the client.-->
<!--```swift-->
<!--client.headers["Authorization"] = "[mytoken]"-->
<!--```-->
<!---->
<!--### Add Timeout-->
<!--Timeout (TimeInterval in seconds) is added via the optional `timeout` property on the client.-->
<!--```swift-->
<!--let client = NetworkingClient(baseURL: "https://jsonplaceholder.typicode.com", timeout: 15)-->
<!--```-->
<!---->
<!--Alternatively,-->
<!---->
<!--```swift-->
<!--client.timeout = 15 -->
<!--```-->

### Cancel a request
Since `Jolt` uses the Combine framework. You just have to cancel the `AnyCancellable` returned by the `sink` call.

```swift
var cancellable = client.get("/posts/1").sink(receiveCompletion: { _ in }) { (json:Any) in
  print(json)
}
```
Later ...
```swift
cancellable.cancel()
```

### Log Network calls
3 log levels are supported: `none`, `debugInformative`, `debugVerbose`
```swift
client.setLogLevel(with: .debugInformative)
```

### Support Decodable parsing.
For a model to be parsable by `Networking`, it needs to conform to the `Decodable` protocol.

### Design a clean api
In order to write a concise api, Networking provides the `NetworkingService` protocol.
This will forward your calls to the underlying client so that your only have to write `get("/route")` instead of `network.get("/route")`, while this is overkill for tiny apis, it definitely keep things concise when working with massive apis.


Given an `Article` model
```swift
struct Article: Codable {
    let id: String
    let title: String
    let content: String
}

Here is what a typical CRUD api would look like :

```swift
struct CRUDApi: NetworkingService {

    var network = NetworkingClient(baseURL: "https://my-api.com")

    // Create
    func create(article a: Article) -> AnyPublisher<Article, Error> {
        post("/articles", params: ["title" : a.title, "content" : a.content])
    }

    // Read
    func fetch(article a: Article) -> AnyPublisher<Article, Error> {
        get("/articles/\(a.id)")
    }

    // Update
    func update(article a: Article) -> AnyPublisher<Article, Error> {
        put("/articles/\(a.id)", params: ["title" : a.title, "content" : a.content])
    }

    // Delete
    func delete(article a: Article) -> AnyPublisher<Void, Error> {
        delete("/articles/\(a.id)")
    }

    // List
    func articles() -> AnyPublisher<[Article], Error> {
        get("/articles")
    }
}
```
