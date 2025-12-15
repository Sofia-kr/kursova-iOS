import Foundation
import Combine

class GameListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var searchText: String = ""
    @Published var selectedGenre: String = "All"
    @Published var myCollection: [Game] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let collectionKey = "myGameCollection"
    let apiKey: String = "077a14bbcde34bdf834c5a9e35ceb091"
    
    init() {
        loadCollection()
        fetchGames()
        
        // Автопошук
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.fetchGames(query: text)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Games
    func fetchGames(query: String = "") {
        var urlString = "https://api.rawg.io/api/games?key=\(apiKey)&search=\(query)"
        if selectedGenre != "All" {
            urlString += "&genres=\(selectedGenre.lowercased())"
        }
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GameResponse.self, decoder: JSONDecoder())
            .replaceError(with: GameResponse(results: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                // Сортуємо за рейтингом
                self?.games = response.results.sorted { $0.rating < $1.rating }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Game Collection
    func addToCollection(_ game: Game) {
        if !myCollection.contains(game) {
            myCollection.append(game)
            saveCollection()
        }
    }
    
    func removeFromCollection(_ game: Game) {
        myCollection.removeAll { $0.id == game.id }
        saveCollection()
    }
    
    func isInCollection(_ game: Game) -> Bool {
        myCollection.contains(game)
    }
    
    func saveCollection() {
        if let data = try? JSONEncoder().encode(myCollection) {
            UserDefaults.standard.set(data, forKey: collectionKey)
        }
    }
    
    func loadCollection() {
        if let data = UserDefaults.standard.data(forKey: collectionKey),
           let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            self.myCollection = decoded
        }
    }
    
    func fetchGameDetails(id: Int, completion: @escaping (GameDetails?) -> Void) {
        guard let url = URL(string: "https://api.rawg.io/api/games/\(id)?key=\(apiKey)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion(nil); return }
            let details = try? JSONDecoder().decode(GameDetails.self, from: data)
            DispatchQueue.main.async { completion(details) }
        }.resume()
    }
}
