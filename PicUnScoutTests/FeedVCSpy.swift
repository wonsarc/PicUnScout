@testable import PicUnScout
import Foundation

final class FeedVCSpy: FeedVCProtocol {
    var presenter: (any PicUnScout.FeedPresenterProtocol)?
    
    var currentFilter: String?
    var oldCountView: Int?
    var newCountView: Int?
    var didCallUpdateTableViewAnimated = false
    var images: [PicUnScout.Image] = []

    func updateCollectionViewAnimated(oldCount: Int, newCount: Int) {
        didCallUpdateTableViewAnimated = true
        oldCountView = oldCount
        newCountView = newCount

    }
}
