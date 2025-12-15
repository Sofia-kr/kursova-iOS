import Foundation

struct GameDetails: Codable {
    let id: Int
    let name: String
    let description_raw: String
    let platforms: [PlatformWrapper]

    struct PlatformWrapper: Codable {
        let platform: Platform
    }

    struct Platform: Codable {
        let name: String
    }
}
