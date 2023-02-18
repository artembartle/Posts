// Developed by Artem Bartle

import Foundation

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
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
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
