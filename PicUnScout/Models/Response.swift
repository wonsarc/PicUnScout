struct UnsplashResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [ResultItem]

}
struct ResultItem: Decodable {
    let id: String
    let updatedAt: String
    let likes: Int
    let width: Int
    let height: Int
    let user: User
    let altDescription: String?
    let urls: Url
}
