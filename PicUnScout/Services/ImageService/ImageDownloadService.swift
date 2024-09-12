import UIKit

enum ImageStateEnum {
    case loading
    case error
    case finished(UIImage)
}

enum ImageError: Error {
    case invalidURL
    case invalidData
}

typealias ResultImageError = (Result<UIImage, Error>) -> Void

protocol ImageDownloadServiceProtocol {
    func downloadImage(on url: String, completion: @escaping ResultImageError)
}

final class ImageDownloadService: ImageDownloadServiceProtocol {

    // MARK: - Private Properties

    private let networkClient = NetworkClient()

    // MARK: - Public Methods

    func downloadImage(on stringUrl: String, completion: @escaping ResultImageError) {
        guard let imageURL = URL(string: stringUrl) else {
            completion(.failure(ImageError.invalidURL))
            return
        }

        let request = networkClient.createRequest(url: imageURL, httpMethod: .GET)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(ImageError.invalidData))
                return
            }

            completion(.success(image))
        }.resume()
    }
}
