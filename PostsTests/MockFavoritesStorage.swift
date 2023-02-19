// Developed by Artem Bartle

import Foundation

class MockFavoritesStorage<Identifier: Hashable>: FavoritesStorage {
    var favorites = Set<Identifier>()
    
    func isFavorite(id: Identifier) -> Bool {
        return favorites.contains(id)
    }
    
    func addToFavorites(id: Identifier) {
        favorites.insert(id)
    }
    
    func removeFromFavorites(id: Identifier) {
        favorites.remove(id)
    }
}
