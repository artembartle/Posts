// Developed by Artem Bartle

import Factory

extension Container {
    static let favoritesStorage = Factory<any FavoritesStorage<Post.ID>>(scope: .singleton) {
        UserDefaultsFavorites<Post.ID>()
    }
    
    static let apiClient = Factory<APIClient> {
        LiveAPIClient()
    }
    
    static let postsRepository = Factory<PostsRepository>(scope: .singleton) {
        PostsRepositoryImpl()
    }
    
    static let loginViewModel = Factory<LoginViewModel> { LoginViewModel() }
    
    static let feedViewModel = Factory<FeedViewModel> { FeedViewModel() }
}
