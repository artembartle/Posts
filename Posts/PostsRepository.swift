// Developed by Artem Bartle

import Foundation
import Factory

struct Post: Equatable, Identifiable {
    let id: String
    let title: String
    let body: String
    var favorite: Bool
    
    init(id: String, title: String, body: String, favorite: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.favorite = favorite
    }
}

extension Post {
    static func stub(favorite: Bool = false) -> Self {
        Self(dto: PostDTO.stub(), favorite: favorite)
    }
    
    init(dto: PostDTO, favorite: Bool = false) {
        self.id = dto.id
        self.title = dto.title
        self.body = dto.body
        self.favorite = favorite
    }
}

enum RepositoryError: Error, Equatable {
    case parsing
    case network
    case incorrectUserId
    case apiError(error: APIError)
    case unknown(description: String)
}

protocol PostsRepository {
    func getPosts(userID: String) async throws -> [Post]
    func applyFavoriteAction(post: Post) -> Post
}

class PostsRepositoryImpl: PostsRepository {
    @Injected(Container.favoritesStorage) private var favoritesStorage
    @Injected(Container.apiClient) private var api
    
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
