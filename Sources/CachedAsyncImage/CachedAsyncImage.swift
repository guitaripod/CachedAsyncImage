import Combine
import Foundation
import SwiftUI
import UIKit

/// Protocol that defines the requirements for an image caching system.
public protocol ImageCache {
    /// Subscript to get or set images for a URL.
    subscript(_ url: URL) -> UIImage? { get set }
}

/// A default implementation of `ImageCache` using `NSCache` to store images.
open class DefaultImageCache: ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    public init() {}
    
    /// Access images by subscripting with a URL.
    ///
    /// - Parameter url: The URL of the image to be fetched or stored.
    public subscript(_ url: URL) -> UIImage? {
        get {
            cache.object(forKey: url as NSURL)
        }
        set {
            newValue == nil
            ? cache.removeObject(forKey: url as NSURL)
            : cache.setObject(newValue!, forKey: url as NSURL)
        }
    }
}

/// A SwiftUI view that loads and displays images from a URL, with caching.
///
/// Usage:
///
/// ```swift
/// CachedAsyncImage(
///     url: URL(string: "https://example.com/image.jpg"),
///     placeholder: Image(systemName: "photo"),
///     errorImage: Image(systemName: "multiply.circle")
/// )
/// ```
public struct CachedAsyncImage: View {
    @StateObject private var viewModel: ViewModel
    
    public var placeholder: Image
    public var errorImage: Image
    
    /// Initializes a new instance of `CachedAsyncImage`.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - placeholder: A view to display while the image is loading. Defaults to a system image.
    ///   - errorImage: A view to display if the image loading fails. Defaults to a system image.
    ///   - cache: An optional `ImageCache` instance for custom caching behavior. Defaults to `DefaultImageCache`.
    public init(
        url: URL?,
        placeholder: Image = Image(systemName: "photo"),
        errorImage: Image = Image(systemName: "multiply.circle"),
        cache: ImageCache = DefaultImageCache()
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(url: url, cache: cache))
        self.placeholder = placeholder
        self.errorImage = errorImage
    }
    
    public var body: some View {
        content
            .onAppear(perform: viewModel.loadImage)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading, .noURL:
            placeholder
        case .failed:
            errorImage
                .onTapGesture {
                    viewModel.loadImage()
                }
        case .loaded(let image):
            Image(uiImage: image)
                .resizable()
        }
    }
}

// MARK: - ViewModel for CachedAsyncImage

extension CachedAsyncImage {
    
    /// ViewModel managing the state of the image loading process.
    final class ViewModel: ObservableObject {
        @Published var state: LoadState = .idle
        
        enum ImageLoadingError: Error {
            case urlError
            case decodingError
            case networkError(Error)
        }
        
        enum LoadState {
            case idle
            case loading
            case loaded(UIImage)
            case failed(ImageLoadingError)
            case noURL
        }
        
        public init(url: URL?, cache: ImageCache) {
            self.url = url
            self.cache = cache
            if url == nil {
                state = .noURL
            }
        }
        
        func loadImage() {
            guard let url else {
                state = .noURL
                return
            }
            
            if let image = cache[url] {
                state = .loaded(image)
                return
            }
            
            state = .loading
            cancellable = Future<UIImage, ImageLoadingError> { promise in
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let error = error {
                        promise(.failure(.networkError(error)))
                        return
                    }
                    guard let data = data, let image = UIImage(data: data) else {
                        promise(.failure(.decodingError))
                        return
                    }
                    promise(.success(image))
                }.resume()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    state = .failed(error)
                }
            }, receiveValue: { [unowned self] image in
                state = .loaded(image)
                cache[url] = image
            })
        }
        
        // MARK: Private
        
        private let url: URL?
        private var cache: ImageCache
        private var cancellable: AnyCancellable?
    }
}

// MARK: - Equatable for LoadState

extension CachedAsyncImage.ViewModel.LoadState: Equatable {
    
    static func == (
        lhs: CachedAsyncImage.ViewModel.LoadState,
        rhs: CachedAsyncImage.ViewModel.LoadState
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.failed, .failed):
            return true
        case (let .loaded(lhsImage), let .loaded(rhsImage)):
            return lhsImage.pngData() == rhsImage.pngData()
        default:
            return false
        }
    }
}
