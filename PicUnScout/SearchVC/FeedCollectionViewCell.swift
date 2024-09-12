import UIKit

final class FeedCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties

    static let reuseIdentifier = "ImageCell"

    var imageState: ImageStateEnum = .loading {
        didSet {
            switch imageState {
            case .loading:
                activityIndicator.startAnimating()
            case .error:
                activityIndicator.stopAnimating()
                print("error")
            case .finished(let image):
                cellView.image = image
                activityIndicator.stopAnimating()
            }
        }
    }

    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }

    var dateText: Date? {
        didSet {
            if let date = dateText {
                dateLabel.text = Self.dateFormatter.string(from: date)
            } else {
                dateLabel.text = nil
            }
        }
    }

    var likeCount: Int = 0 {
        didSet {
            likeButton.setTitle(" \(likeCount)", for: .normal)
        }
    }

    // MARK: - Private Properties

    private var cellView = UIImageView()
    private var likeButton = UIButton()
    private var descriptionLabel = UILabel()
    private var dateLabel = UILabel()
    private var overlayView = UIView()
    private var activityIndicator = UIActivityIndicatorView(style: .medium)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter
    }()

    // MARK: - Initializers

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides Methods

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
        setupOverlayView()
        setupLikeButton()
        setupDescriptionLabel()
        setupDateLabel()
        setupActivityIndicator()
    }

    // MARK: - Private Methods

    private func setupCellView() {
        contentView.addSubview(cellView)
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
        cellView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
        ])
    }

    private func setupOverlayView() {
        contentView.addSubview(overlayView)
        overlayView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        overlayView.layer.cornerRadius = 10
        overlayView.layer.masksToBounds = true

        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: cellView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor),
        ])
    }

    private func setupLikeButton() {
        overlayView.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeButton.isEnabled = false
        likeButton.setTitleColor(.white, for: .normal)
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)

        likeButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8).isActive = true
        likeButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8).isActive = true
    }

    private func setupDescriptionLabel() {
        overlayView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .white

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8)
        ])
    }

    private func setupDateLabel() {
        overlayView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.numberOfLines = 0
        dateLabel.textColor = .white

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8)
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
