// Developed by Artem Bartle

import SwiftUI

protocol FavoritesStorage<Identifier> {
    associatedtype Identifier
    func isFavorite(id: Identifier) -> Bool
    func addToFavorites(id: Identifier)
    func removeFromFavorites(id: Identifier)
}

fileprivate enum UserDefaultsConstant {
    static let backingSetKey = "Favorites"
}

class UserDefaultsFavorites<Identifier: Hashable>: FavoritesStorage {
    fileprivate typealias Constant = UserDefaultsConstant
    
    private let userDefaults = UserDefaults.standard
    
    private func backingSet() -> Set<Identifier> {
        guard let backingArray = userDefaults.object(forKey: Constant.backingSetKey) as? Array<Identifier> else {
            return Set()
        }
        
        return Set(backingArray)
    }
    
    private func saveBackingSet(set: Set<Identifier>) {
        userDefaults.set(Array(set), forKey: Constant.backingSetKey)
    }
    
    func isFavorite(id: Identifier) -> Bool {
        let favorites = backingSet()
        return favorites.contains(id)
    }
    
    func addToFavorites(id: Identifier) {
        var favorites = backingSet()
        favorites.insert(id)
        saveBackingSet(set: favorites)
    }
    
    func removeFromFavorites(id: Identifier) {
        var favorites = backingSet()
        favorites.remove(id)
        saveBackingSet(set: favorites)
    }
}

@MainActor
class PostViewModel: ObservableObject {
    private let favoritesStorage: any FavoritesStorage<String> = UserDefaultsFavorites()
    let id: String
    let title: String
    let body: String
    @Published var isFavorite = false
    
    init(post: Post) {
        self.id = post.id
        self.title = post.title
        self.body = post.body
        self.isFavorite = favoritesStorage.isFavorite(id: post.id)
    }
    
    func triggerFavoriteAction() {
        if isFavorite {
            favoritesStorage.removeFromFavorites(id: id)
        } else {
            favoritesStorage.addToFavorites(id: id)
        }
        isFavorite = !isFavorite
    }
}

struct PostView: View {
    typealias ViewModel = PostViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.title)
                Text(viewModel.body)
                    .font(.body)
            }
            
            HStack {
                Spacer()
                VStack {
                    Button {
                        viewModel.triggerFavoriteAction()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    }
                    .padding()
                    Spacer()
                }

            }

        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(viewModel: PostViewModel(post: Post.mock))
    }
}
