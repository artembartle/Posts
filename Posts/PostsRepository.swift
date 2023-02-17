// Developed by Artem Bartle

import Foundation

struct Post: Equatable {
    let id: String
    let title: String
    let body: String
    var favorite: Bool
    
    init(dto: PostDTO, favorite: Bool = false) {
        self.id = dto.id
        self.title = dto.title
        self.body = dto.body
        self.favorite = favorite
    }
}

extension Post {
    static let mock = Self(dto: PostDTO.mock, favorite: true)
}

protocol PostsRepository {
    func getPosts(userID: String) async throws -> [Post]
    func applyFavoriteAction(post: Post) -> Post
}

class PostsRepositoryImpl: PostsRepository {
    private let favoritesStorage: any FavoritesStorage<String> = UserDefaultsFavorites()
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }
    
    func getPosts(userID: String) async throws -> [Post] {
        let dtos = try await api.loadPosts(userID: userID)
        return dtos.map { dto in
            let favorite = favoritesStorage.isFavorite(id: dto.id)
            return Post(dto: dto, favorite: favorite)
        }
    }
    
    func applyFavoriteAction(post: Post) -> Post {
        var updatedPost = post
        updatedPost.favorite = !updatedPost.favorite
        
        if updatedPost.favorite {
            favoritesStorage.addToFavorites(id: updatedPost.id)
        } else {
            favoritesStorage.removeFromFavorites(id: updatedPost.id)
        }
        
        return updatedPost
    }
}
