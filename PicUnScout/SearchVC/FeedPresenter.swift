import Foundation

protocol FeedPresenterProtocol {
    var view: FeedVCProtocol? { get set }
    var imagesListService: ImageServiceProtocol { get set }
    var imageDownloadService: ImageDownloadServiceProtocol { get set }

    func fetchImages(with filter: String)
    func updateCollectionViewAnimated(oldCount: Int, newCount: Int)
    func observeDataChanges()
    func willDisplayCell(at indexPath: IndexPath, photosCount: Int)
    func downloadImagePhoto(_ photoImageURL: String, completion: @escaping ResultImageError)
}

final class FeedPresenter: FeedPresenterProtocol {

    // MARK: - Public Properties

    weak var view: FeedVCProtocol?
    var profileImageListViewObserver: NSObjectProtocol?
    var imagesListService: ImageServiceProtocol = ImageService()
    var imageDownloadService: ImageDownloadServiceProtocol = ImageDownloadService()

    // MARK: - Initializers

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    func fetchImages(with filter: String) {
        imagesListService.fetchImagesNextPage(with: filter)
    }

    func downloadImagePhoto(_ photoImageURL: String, completion: @escaping ResultImageError) {
        imageDownloadService.downloadImage(on: photoImageURL, completion: completion)
    }

    func observeDataChanges() {
        profileImageListViewObserver = NotificationCenter.default.addObserver(
            forName: ImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDataChangeNotification()
        }
    }

    func updateCollectionViewAnimated(oldCount: Int, newCount: Int) {
        view?.updateCollectionViewAnimated(oldCount: oldCount, newCount: newCount)
    }

    func willDisplayCell(at indexPath: IndexPath, photosCount: Int) {
        guard let filter = view?.currentFilter else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchImages(with: filter)
        }
    }

    // MARK: - Private Methods

    private func handleDataChangeNotification() {
        let oldCount = view?.images.count ?? 0
        view?.images = imagesListService.images
        let newCount = view?.images.count ?? oldCount

        updateCollectionViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}
