import SwiftUI

struct MyCollectionView: View {
    @ObservedObject var viewModel: GameListViewModel
    
    var body: some View {
        ZStack {
            // Фон, що покриває весь екран
            LinearGradient(
                colors: [Color.cyan.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()  // Робимо фон не обмеженим safe area

            VStack {
                List {
                    if viewModel.myCollection.isEmpty {
                        Text("Колекція пуста")
                            .foregroundColor(.black)
                    } else {
                        ForEach(viewModel.myCollection) { game in
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
                            }
                        }
                        .onDelete { idx in
                            viewModel.myCollection.remove(atOffsets: idx)
                            viewModel.saveCollection()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Моя колекція")
        .toolbar { EditButton() }
    }
}
