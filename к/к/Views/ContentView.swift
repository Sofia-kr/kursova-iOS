import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameListViewModel()
    let genres = ["All", "Action", "Adventure", "Shooter", "Indie"]
    @State private var isSortedByRating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.cyan.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Пошук гри", text: $viewModel.searchText)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.leading, 8)
                        
                        Button(action: {
                            viewModel.games.sort { $0.rating > $1.rating }
                            isSortedByRating = true
                        }) {
                            Text("Рейтинг ⬇")
                                .bold()
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    LinearGradient(colors: [Color.white.opacity(0.4)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Фільтр жанру
                    Picker("Жанр", selection: $viewModel.selectedGenre) {
                        ForEach(genres, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(10)
                    .onChange(of: viewModel.selectedGenre) { _ in
                        viewModel.fetchGames(query: viewModel.searchText)
                        isSortedByRating = false
                    }
                    
                    // Список ігор через ScrollView + LazyVStack
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.games) { game in
                                NavigationLink(destination: GameDetailView(game: game, viewModel: viewModel)) {
                                    HStack {
                                        AsyncImage(url: URL(string: game.background_image ?? "")) { img in
                                            img.resizable()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 80, height: 50)
                                        .cornerRadius(6)
                                        
                                        VStack(alignment: .leading) {
                                            Text(game.name)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            Text("Rating: \(String(format: "%.1f", game.rating))")
                                                .font(.subheadline)
                                                .foregroundColor(.black.opacity(0.7))
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Game Browser")
            .toolbar {
                NavigationLink("Моя колекція") {
                    MyCollectionView(viewModel: viewModel)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
