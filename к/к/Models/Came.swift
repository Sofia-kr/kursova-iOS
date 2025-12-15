import Foundation

struct Game: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let background_image: String?
    let rating: Double
    let genres: [Genre]?

    struct Genre: Codable, Equatable {
        let name: String
    }
}
struct GameResponse: Codable {
    let results: [Game]
}
