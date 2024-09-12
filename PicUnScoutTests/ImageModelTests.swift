import XCTest
@testable import PicUnScout

final class ImageModelTests: XCTestCase {

    var image1: Image!
    var image2: Image!
    var image3: Image!

    override func setUp() {
        super.setUp()

        let date = Date()

        image1 = Image(id: "1",
                       author: "Author1",
                       size: CGSize(width: 100, height: 100),
                       date: date,
                       likeCount: 100,
                       description: "Description1",
                       thumbImageURL: "http://example.com/thumb1.jpg",
                       largeImageURL: "http://example.com/large1.jpg")

        image2 = Image(id: "1",
                       author: "Author1",
                       size: CGSize(width: 100, height: 100),
                       date: date,
                       likeCount: 100,
                       description: "Description1",
                       thumbImageURL: "http://example.com/thumb1.jpg",
                       largeImageURL: "http://example.com/large1.jpg")

        image3 = Image(id: "2",
                       author: "Author2",
                       size: CGSize(width: 200, height: 200),
                       date: date,
                       likeCount: 200,
                       description: "Description2",
                       thumbImageURL: "http://example.com/thumb2.jpg",
                       largeImageURL: "http://example.com/large2.jpg")
    }

    override func tearDown() {
        image1 = nil
        image2 = nil
        image3 = nil
        super.tearDown()
    }

    func testImagesEquality_WhenImagesAreEqual() {
        XCTAssertEqual(image1, image2, "Images should be equal")
    }

    func testImagesEquality_WhenImagesAreNotEqual() {
        XCTAssertNotEqual(image1, image3, "Images should not be equal")
    }

    func testImagesArrayEquality_WhenArraysAreEqual() {
        let array1 = [image1, image3]
        let array2 = [image2, image3]

        XCTAssertEqual(array1, array2, "Image arrays should be equal")
    }

    func testImagesArrayEquality_WhenArraysAreNotEqual() {
        let array1 = [image1]
        let array2 = [image3]

        XCTAssertNotEqual(array1, array2, "Image arrays should not be equal")
    }
}
