import Foundation

protocol ImageServiceProtocol {
    var images: [Image] { get }
    func fetchImagesNextPage(with filter: String)
}

final class ImageService: ImageServiceProtocol {

    // MARK: - Public Properties

    static let didChangeNotification = Notification.Name(rawValue: "ImageServiceDidChange")

    // MARK: - Private Properties

    private let baseUrl = URL(string: "https://api.unsplash.com")!
    private let accessKeyStandard = "bJwardQNhRa51vP0_byJw1lF0WfDzB8vk42QjJxdJ90"
    private let photosSearch = "/search/photos"
    private let networkClient = NetworkClient()
    private var currentFilter: String?
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    private let perPage = 30
    private var lastLoadedPage = 0
    private (set) var images: [Image] = []
    private var task: URLSessionTask?

    // MARK: - Public Methods

    func fetchImagesNextPage(with filter: String) {
        assert(Thread.isMainThread)

        if currentFilter != filter {
            images = []
            lastLoadedPage = 0
            currentFilter = filter
        }

        if task != nil {
            return
        }

        let nextPage = lastLoadedPage + 1

        let url = networkClient.createURL(
            url: "\(baseUrl)\(photosSearch)",
            queryItems: [
                URLQueryItem(name: "page", value: String(nextPage)),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "query", value: filter)
            ]
        )

        var request = networkClient.createRequest(
            url: url,
            httpMethod: .GET
        )

        request.setValue("Client-ID \(accessKeyStandard)", forHTTPHeaderField: "Authorization")

        task = createPhotosTask(request: request, nextPage: nextPage)
        task?.resume()
    }

    // MARK: - Private Methods

    private func createPhotosTask(request: URLRequest, nextPage: Int) -> URLSessionTask? {
        return urlSession.objectTask(
            for: request,
            completion: {
                [weak self ] (result: Result<UnsplashResponse, Error>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let listImage):
                        print("Total pages: \(listImage.totalPages)")
                        guard nextPage <= listImage.totalPages else {
                            print("Страница больше нет")
                            self.task = nil
                            return
                        }
                        for imageData in listImage.results {
                            let image = Image(
                                id: imageData.id,
                                author: imageData.user.name,
                                size:  CGSize(width: imageData.width, height: imageData.height),
                                date: self.dateFormatter.date(from: imageData.updatedAt),
                                likeCount: imageData.likes,
                                description: imageData.altDescription,
                                thumbImageURL: imageData.urls.thumb,
                                largeImageURL: imageData.urls.full
                            )

                            self.images.append(image)
                        }
                        self.lastLoadedPage = nextPage
                        self.createNotification()
                    case .failure(let error):
                        print("Error loading images: \(error)")
                    }
                    self.task = nil
                }
            })
    }

    private func createNotification() {
        NotificationCenter.default
            .post(
                name: ImageService.didChangeNotification,
                object: self,
                userInfo: ["images": images]
            )
    }
}
