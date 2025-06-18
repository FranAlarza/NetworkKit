# NetworkKit

**NetworkKit** is a lightweight, async/await-based Swift package designed to simplify HTTP networking in Swift projects. It provides a clean abstraction for sending requests, uploading and downloading files, and handling errors gracefully.

## ✨ Features

- Clean `Endpoint` abstraction
- Async/await support
- JSON decoding out of the box
- File upload and download
- Easy to test (includes `MockHTTPClient`)

## 📦 Installation

### Swift Package Manager

In Xcode:

1. Go to **File > Add Packages...**
2. Enter the URL of this repository:
   ```
   https://github.com/FranAlarza/NetworkKit.git
   ```
3. Select the version (e.g. `1.0.0`)

## 🛠 Usage

### Define an Endpoint

```swift
struct GetUsersEndpoint: Endpoint {
    var path: String { "https://jsonplaceholder.typicode.com/users" }
    var method: HTTPMethod { .get }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
}
```

### Fetch Data

```swift
let client = HTTPClient()
let users: [User] = try await client.send(GetUsersEndpoint(), as: [User].self)
```

### Upload a File

```swift
let fileURL = URL(filePath: "/path/to/file.pdf")
let response: UploadResponse = try await client.upload(MyUploadEndpoint(), fileURL: fileURL, as: UploadResponse.self)
```

### Download a File

```swift
let destination = FileManager.default.temporaryDirectory.appendingPathComponent("file.pdf")
try await client.download(MyDownloadEndpoint(), to: destination)
```

## 🧪 Testing

Use `MockHTTPClient` to simulate network behavior in unit tests without real HTTP calls.

```swift
let mock = MockHTTPClient()
mock.result = .success(mockJSONData)

let result: MyModel = try await mock.send(MyEndpoint(), as: MyModel.self)
```

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
