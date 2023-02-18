// Developed by Artem Bartle

import Factory

extension Container {
    static let favoritesStorage = Factory<any FavoritesStorage<Post.ID>> { UserDefaultsFavorites<Post.ID>() }
    
    static let apiClient = Factory<APIClient> {
        let client = MockAPIClient()
        let posts = (0..<10).map { PostDTO(id: String($0), title: "Title", body: PostDTO.stub.body) }
        client.response = .success(posts)
        return client
    }
    
    static let postsRepository = Factory<PostsRepository>(scope: .singleton) { PostsRepositoryImpl() }
    
    static let feedViewModel = Factory<PostsViewModel> { PostsViewModel() }
}
