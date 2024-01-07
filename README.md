# CachedAsyncImage

CachedAsyncImage is a Swift package offering an efficient and easy-to-use image caching solution for SwiftUI applications. It provides seamless image caching functionality, ensuring fast and reliable image loading.

## Features

- Asynchronous image loading and caching.
- Easy integration with SwiftUI.
- Customizable placeholder and error images.
- Efficient memory usage by leveraging `NSCache`.

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.3+
- Xcode 12.0+

## Installation

### Swift Package Manager

You can add CachedAsyncImage to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages** > **Add Package Dependency...**
2. Enter `https://github.com/[YourGitHubUsername]/CachedAsyncImage.git` into the package repository URL text field

## Usage

`CachedAsyncImage` is a Swift package designed for SwiftUI applications, providing an efficient mechanism for asynchronously loading and caching images from the web. 

### Components

#### `ImageCache` Protocol

```swift
protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}
```

- **Purpose**: Defines a contract for an image caching system.
- **Subscript**: Allows getting and setting `UIImage` instances associated with a `URL`.

#### `DefaultImageCache` Class

```swift
class DefaultImageCache: ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    subscript(_ url: URL) -> UIImage? {
        // Implementation
    }
}
```

- **Description**: A default implementation of `ImageCache`, using `NSCache` to store `UIImage` instances.
- **Usage**: Automatically used by `CachedAsyncImage` if no custom cache is provided.

#### `CachedAsyncImage` View

```swift
struct CachedAsyncImage: View {
    // Properties and Initializer
}
```

- **Description**: A SwiftUI view that loads and displays images from a URL, with caching.
- **Initialization Parameters**:
  - `url`: The URL of the image to load.
  - `placeholder`: A view to display while the image is loading.
  - `errorImage`: A view to display if the image loading fails.
  - `cache`: An optional `ImageCache` instance for custom caching behavior.

#### ViewModel for `CachedAsyncImage`

```swift
extension CachedAsyncImage {
    final class ViewModel: ObservableObject {
        // Properties and Functions
    }
}
```

- **Responsibility**: Manages the state of image loading, including caching logic.
- **LoadState**: Enum representing the loading state (`idle`, `loading`, `loaded`, `failed`, `noURL`).

### Example Usage

#### Basic Usage

```swift
import SwiftUI
import CachedAsyncImage

struct ContentView: View {
    var body: some View {
        CachedAsyncImage(
            url: URL(string: "https://example.com/image.jpg"),
            placeholder: Image(systemName: "photo"),
            errorImage: Image(systemName: "multiply.circle")
        )
    }
}
```

#### Custom Cache Implementation

To use a custom cache:

```swift
class MyCustomCache: ImageCache {
    // Custom cache implementation
}

struct ContentView: View {
    var body: some View {
        CachedAsyncImage(
            url: URL(string: "https://example.com/image.jpg"),
            cache: MyCustomCache()
        )
    }
}
```

### Advanced Features

#### Handling Tap Gestures on Error

To reload the image on tapping the error view:

```swift
CachedAsyncImage(
    url: URL(string: "https://example.com/image.jpg"),
    errorImage: Image(systemName: "multiply.circle")
        .onTapGesture {
            // Custom action to handle tap
        }
)
```

#### Customizing Placeholder and Error Images

You can provide custom SwiftUI views for placeholders and error states:

```swift
CachedAsyncImage(
    url: URL(string: "https://example.com/image.jpg"),
    placeholder: Text("Loading..."),
    errorImage: Text("Failed to Load Image")
)
```

### Testing

For unit testing, you can use the provided `MockImageCache` class to simulate different caching scenarios.
