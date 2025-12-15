import SwiftUI
import PhotosUI
import UIKit

struct GameDetailView: View {
    let game: Game
    @ObservedObject var viewModel: GameListViewModel
    @State private var details: GameDetails?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cyan.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                
                if let d = details {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(d.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                        
                        AsyncImage(url: URL(string: game.background_image ?? "")) { img in
                            img.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        
                        Text(d.description_raw)
                            .foregroundColor(.black)
                        
                        Text("Платформи")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ForEach(d.platforms, id: \.platform.name) { p in
                            Text(p.platform.name)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        // Кнопки
                        VStack(spacing: 12) {
                            if viewModel.isInCollection(game) {
                                GradientButton(title: "Видалити з колекції", color: .red) {
                                    viewModel.removeFromCollection(game)
                                }
                            } else {
                                GradientButton(title: "Додати до колекції", color: .blue) {
                                    viewModel.addToCollection(game)
                                }
                            }
                            
                            GradientButton(title: "Зберегти постер", color: .green) {
                                saveImageToPhotos(urlString: game.background_image) { success in
                                    alertMessage = success ? "Постер збережено!" : "Помилка збереження"
                                    showAlert = true
                                }
                            }
                        }
                    }
                    .padding()
                } else {
                    ProgressView()
                        .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("Деталі")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Ок", role: .cancel) {}
        }
        .onAppear {
            viewModel.fetchGameDetails(id: game.id) { fetched in
                self.details = fetched
            }
        }
    }
    
}

struct GradientButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [color.opacity(0.7), color.opacity(0.5)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(12)
                .shadow(radius: 4)
        }
    }
}

func saveImageToPhotos(urlString: String?, completion: @escaping (Bool) -> Void) {
    guard let urlString = urlString, let url = URL(string: urlString) else {
        completion(false)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data, let image = UIImage(data: data) else {
            completion(false)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        completion(true)
    }.resume()
}
