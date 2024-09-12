@testable import PicUnScout
import XCTest

final class FeedPresenterTests: XCTestCase {
    private let photos = [Image(id: "1",
                               author: "Author1",
                               size: CGSize(width: 100, height: 100),
                               date: Date(),
                               likeCount: 100,
                               description: "Description1",
                               thumbImageURL: "http://example.com/thumb1.jpg",
                               largeImageURL: "http://example.com/large1.jpg")
                          ]

    func testFetchPhotos() {
        // given
        let presenter = FeedPresenter()
        let imagesListService = ImagesListServiceSpy()
        presenter.imagesListService = imagesListService

        // when
        presenter.fetchImages(with: "test")

        // then
        XCTAssertTrue(imagesListService.didFetchPhotosNextPage)
    }

    func testUpdateTableViewAnimated() {
        // given
        let oldCountPresenter = 1
        let newCountPresenter = 2
        let presenter = FeedPresenter()
        let view = FeedVCSpy()
        presenter.view = view

        // when
        presenter.updateCollectionViewAnimated(oldCount: oldCountPresenter, newCount: newCountPresenter)

        // then
        XCTAssertTrue(view.didCallUpdateTableViewAnimated)
        XCTAssertEqual(view.newCountView, newCountPresenter)
        XCTAssertEqual(view.oldCountView, oldCountPresenter)
    }

    func testObserveDataChanges() {
        // given
        let presenter = FeedPresenter()

        // when
        presenter.observeDataChanges()

        // then
        XCTAssertNotNil(presenter.profileImageListViewObserver)
    }
}
