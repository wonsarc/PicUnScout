import UIKit

final class SingleImageVC: UIViewController {

    // MARK: - Public Properties

    var imageURL: String? {
        didSet {
            downloadImage()
        }
    }

    var authorName: String? {
        didSet {
            authorLabel.text = "Author: \(authorName ?? "")"
        }
    }

    var descriptionImage: String? {
        didSet {
            descriptionLabel.text = descriptionImage
        }
    }

    // MARK: - Private Properties

    private let imageService = ImageDownloadService()

    private let authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.boldSystemFont(ofSize: 16)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()

    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()

    private let photoSingleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let sharedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrowshape.turn.up.backward"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()
        setupImageView()
        setupSharedButton()
        setupSaveButton()
        setupDescriptionLabel()
        setupAuthorLabel()
        setupActivityIndicator()
        downloadImage()
    }

    // MARK: - Private Methods

    private func setupImageView() {
        view.addSubview(photoSingleImageView)

        NSLayoutConstraint.activate([
            photoSingleImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            photoSingleImageView.heightAnchor.constraint(equalTo: photoSingleImageView.widthAnchor),
            photoSingleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoSingleImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16)
        ])
    }

    private func setupSharedButton() {
        view.addSubview(sharedButton)
        sharedButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            sharedButton.widthAnchor.constraint(equalToConstant: 44),
            sharedButton.heightAnchor.constraint(equalToConstant: 44),
            sharedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sharedButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -16)
        ])
    }

    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }

    private func setupSaveButton() {
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 16)
        ])
    }

    private func setupAuthorLabel() {
        view.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: photoSingleImageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func downloadImage() {
        guard isViewLoaded else { return }
        guard let imageURL = imageURL else { return }

        activityIndicator.startAnimating()

        imageService.downloadImage(on: imageURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.photoSingleImageView.image = image
                case .failure(let error):
                    print("Image download error: \(error)")
                }
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16)
        ])
    }

    @objc private func didTapBackButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.view.alpha = 0.0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }

    @objc private func didTapShareButton() {
        guard let image = photoSingleImageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    @objc private func didTapSaveButton() {
        guard let image = photoSingleImageView.image else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title: String
        let message: String

        if error != nil {
            title = "Ошибка"
            message = "Предоставьте доступ к медиатеке"
        } else {
            title = "Успех"
            message = "Изображение успешно сохранено в галерею!"
        }
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
