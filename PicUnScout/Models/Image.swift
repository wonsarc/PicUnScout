import Foundation

struct Image: Decodable, Equatable {
    let id: String
    let author: String
    let size: CGSize
    let date: Date?
    let likeCount: Int
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String

    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.id == rhs.id &&
        lhs.author == rhs.author &&
        lhs.size == rhs.size &&
        lhs.date == rhs.date &&
        lhs.likeCount == rhs.likeCount &&
        lhs.description == rhs.description &&
        lhs.thumbImageURL == rhs.thumbImageURL &&
        lhs.largeImageURL == rhs.largeImageURL
    }
}

extension Array where Element == Image {
    static func == (lhs: [Image], rhs: [Image]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (index, element) in lhs.enumerated() where element != rhs[index] {
            return false
        }
        return true
    }
}
