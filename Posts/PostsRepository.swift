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
        self.id = String(dto.id)
        self.title = dto.title
        self.body = dto.body
        self.favorite = favorite
    }
}

enum RepositoryError: Equatable {
    case apiError(error: APIError)
    case unknown(description: String)
}

extension RepositoryError: LocalizedError {
    var localizedDescription: String? {
        switch self {
        case .apiError(let apiError):
            return apiError.localizedDescription
    
        case .unknown(let decription):
            return decription
        }
    }
}

protocol PostsRepository {
    func getPosts(userID: String) async throws -> [Post]
    func applyFavoriteAction(post: Post) -> Post
}

class PostsRepositoryImpl: PostsRepository {
    @Injected(Container.favoritesStorage) private var favoritesStorage
    @Injected(Container.apiClient) private var api
    
    func getPosts(userID: String) async throws -> [Post] {
        do {
            let dtos = try await api.loadPosts(userID: userID)
            return dtos.map { dto in
                let favorite = favoritesStorage.isFavorite(id: String(dto.id))
                return Post(dto: dto, favorite: favorite)
            }
        } catch let apiError as APIError {
            throw RepositoryError.apiError(error: apiError)
        } catch {
            throw RepositoryError.unknown(description: error.localizedDescription)
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
