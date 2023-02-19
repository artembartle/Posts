// Developed by Artem Bartle

import Foundation
import Combine
import Factory

extension Container {
    static func setupMocks() {
        favoritesStorage.register {
            guard let userDefaults = UserDefaults(suiteName: #file) else {
                fatalError()
            }
            userDefaults.removePersistentDomain(forName: #file)
            return UserDefaultsFavorites<Post.ID>(userDefaults: userDefaults)
        }
        
        apiClient.register {
            MockAPIClient()
        }
    }
}
