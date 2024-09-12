@testable import PicUnScout
import Foundation

final class ImagesListServiceSpy: ImageServiceProtocol {
    
    var images: [PicUnScout.Image] = []
    var didFetchPhotosNextPage: Bool = false

    func fetchImagesNextPage(with filter: String) {
        didFetchPhotosNextPage = true
    }
}
