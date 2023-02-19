// Developed by Artem Bartle

import Factory

extension Container {
    static let favoritesStorage = Factory<any FavoritesStorage<Post.ID>> { UserDefaultsFavorites<Post.ID>() }
    
    static let apiClient = Factory<APIClient> {
//        let client = MockAPIClient()
//        let posts = (0..<10).map { PostDTO.stub(id: String($0)) }
//        client.response = .success(posts)
//        client.response = .failure(APIError.incorrectUserId)
//        return client
        
        LiveAPIClient()
    }
    
    static let postsRepository = Factory<PostsRepository>(scope: .singleton) { PostsRepositoryImpl() }
    
    static let loginViewModel = Factory<LoginViewModel> { LoginViewModel() }
    
    static let feedViewModel = Factory<FeedViewModel> { FeedViewModel() }
}
