import UIKit

protocol FeedVCProtocol: AnyObject {
    var presenter: FeedPresenterProtocol? { get set }
    var currentFilter: String? { get }
    var images: [Image] { get set }
    func updateCollectionViewAnimated(oldCount: Int, newCount: Int)
}

final class FeedVC: UIViewController, FeedVCProtocol {

    // MARK: - Public Properties

    var presenter: FeedPresenterProtocol?
    var currentFilter: String?
    var images: [Image] = []

    // MARK: - Private Properties

    private let displayModeButton = UIButton(type: .custom)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let searchBar = UISearchBar()
    private let sortButton = UIButton(type: .custom)
    private let suggestionsTableView = UITableView()
    private var activityIndicator = UIActivityIndicatorView(style: .medium)

    private var isOneMode: Bool = true
    private var searchHistory: [String] = []
    private var filteredResults: [String] = []

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupDisplayModeButton()
        setupSortButton()
        setupSearchBar()
        setupCollectionView()
        setupSuggestionsTableView()
        setupPresenter()
        setupActivityIndicator()
    }

    // MARK: - Public Methods

    func updateCollectionViewAnimated(oldCount: Int, newCount: Int) {

#warning("""
Больше не воспроизводится, но если будет ошибка: exception 'NSInternalInconsistencyException', то
раскомментить строку 54. Закомментить строки 56-66 и 321
""")
        //collectionView.reloadData()

        self.activityIndicator.stopAnimating()

        collectionView.performBatchUpdates({
            if newCount > oldCount {
                let indexPathsToInsert = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }
                collectionView.insertItems(at: indexPathsToInsert)
            } else {
                let indexPathsToDelete = (newCount..<oldCount).map { IndexPath(item: $0, section: 0) }
                collectionView.deleteItems(at: indexPathsToDelete)
            }
        }, completion: nil)
    }

    // MARK: - Private Methods

    private func setupPresenter() {
        presenter = FeedPresenter()
        presenter?.view = self
        presenter?.observeDataChanges()
    }

    private func setupSuggestionsTableView() {
        suggestionsTableView.backgroundColor = .systemBackground
        suggestionsTableView.separatorStyle = .none
        suggestionsTableView.isScrollEnabled = false
        suggestionsTableView.isHidden = true
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false


        view.addSubview(suggestionsTableView)

        NSLayoutConstraint.activate([
            suggestionsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }


    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }


    private func setupDisplayModeButton() {
        displayModeButton.setTitleColor(.systemBlue, for: .normal)
        displayModeButton.translatesAutoresizingMaskIntoConstraints = false
        displayModeButton.setImage(UIImage(systemName: "square.split.bottomrightquarter"), for: .normal)
        displayModeButton.addTarget(self, action: #selector(changeDisplayMode), for: .touchUpInside)

        view.addSubview(displayModeButton)

        NSLayoutConstraint.activate([
            displayModeButton.widthAnchor.constraint(equalToConstant: 44),
            displayModeButton.heightAnchor.constraint(equalToConstant: 44),
            displayModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            displayModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        ])
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Введите запрос"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: -10),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupSortButton() {
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.setTitleColor(.systemBlue, for: .normal)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)

        view.addSubview(sortButton)

        NSLayoutConstraint.activate([
            sortButton.widthAnchor.constraint(equalToConstant: 44),
            sortButton.heightAnchor.constraint(equalToConstant: 44),
            sortButton.trailingAnchor.constraint(equalTo: displayModeButton.leadingAnchor, constant: -16),
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        ])
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
    }

    @objc private func changeDisplayMode() {
        isOneMode.toggle()
        collectionView.reloadData()
    }

    @objc private func showSortOptions() {
        let alertController = UIAlertController(title: "Сортировка", message: "Выберите способ сортировки", preferredStyle: .actionSheet)

        let sortByDateAction = UIAlertAction(title: "По дате", style: .default) { [weak self] _ in
            self?.sortImages(by: .date)
        }

        let sortByLikesAction = UIAlertAction(title: "По лайкам", style: .default) { [weak self] _ in
            self?.sortImages(by: .likes)
        }

        alertController.addAction(sortByDateAction)
        alertController.addAction(sortByLikesAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FeedVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        cell.textLabel?.text = filteredResults[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = filteredResults[indexPath.row]
        searchBar.text = selectedSuggestion
        suggestionsTableView.isHidden = true
        searchBar.resignFirstResponder()
        searchBarSearchButtonClicked(searchBar)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension FeedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCollectionViewCell.reuseIdentifier, for: indexPath) as? FeedCollectionViewCell

        let image = images[indexPath.row]
        cell?.imageState = .loading
        presenter?.downloadImagePhoto(image.thumbImageURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedImage):
                    cell?.imageState = .finished(loadedImage)
                    cell?.descriptionText = image.description
                    cell?.dateText = image.date
                    cell?.likeCount = image.likeCount
                case .failure(let error):
                    cell?.imageState = .error
                    print("Ошибка при загрузке изображения: \(error)")
                }
            }
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = isOneMode ? view.bounds.width : (view.bounds.width - 5) / 2
        return CGSize(width: width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == images.count - 1 {
            activityIndicator.startAnimating()
            presenter?.willDisplayCell(at: indexPath, photosCount: images.count)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        let singleImageVC = SingleImageVC()

        singleImageVC.imageURL = image.largeImageURL
        singleImageVC.authorName = image.author
        singleImageVC.descriptionImage = image.description

        singleImageVC.modalPresentationStyle = .overFullScreen

        UIView.transition(with: self.view.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.present(singleImageVC, animated: false, completion: nil)
        }, completion: nil)
    }
}

// MARK: - UISearchBarDelegate

extension FeedVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredResults = searchHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
            suggestionsTableView.isHidden = filteredResults.isEmpty
        } else {
            filteredResults = []
            suggestionsTableView.isHidden = true
        }
        suggestionsTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            if !searchHistory.contains(text) {
                searchHistory.insert(text, at: 0)
                if searchHistory.count > 5 {
                    searchHistory.removeLast()
                }
            }
            performSearch(filter: text)
            searchBar.resignFirstResponder()
        }
    }

    private func performSearch(filter: String) {
        if currentFilter != filter {
            let oldCount = images.count
            images = []
            updateCollectionViewAnimated(oldCount: oldCount, newCount: 0)
            currentFilter = filter
        }
        presenter?.fetchImages(with: filter)
    }
}

// MARK: - Sort funcional

enum SortOption {
    case date
    case likes
}

extension FeedVC {

    private func sortImages(by option: SortOption) {
        switch option {
        case .date:
            images.sort {
                guard let date1 = $0.date, let date2 = $1.date else {
                    return $0.date != nil
                }
                return date1 > date2
            }
        case .likes:
            images.sort { $0.likeCount > $1.likeCount }
        }
        collectionView.reloadData()
    }
}
