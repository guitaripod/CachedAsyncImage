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

To use CachedAsyncImage, simply create an instance of `CachedAsyncImage` view in your SwiftUI view and pass the URL of the image you want to display.

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
