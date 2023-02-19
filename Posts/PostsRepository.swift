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

enum RepositoryError: LocalizedError {
    case apiError(error: Error)
    case unknown(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let apiError):
            return apiError.localizedDescription
    
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol PostsRepository {
    func login(userID: String) async throws
    func getPosts() async throws -> [Post]
    func applyFavoriteAction(post: Post) -> Post
}

class PostsRepositoryImpl: PostsRepository {
    @Injected(Container.favoritesStorage) private var favoritesStorage
    @Injected(Container.apiClient) private var api
    
    private var posts: [Post]?

    func login(userID: String) async throws {
        posts = try await loadPosts(userID: userID)
    }
        
    func getPosts() async throws -> [Post] {
        if let posts = posts {
            return posts
        }
        return []
    }
    
    private func loadPosts(userID: String) async throws -> [Post] {
        do {
            let dtos = try await api.loadPosts(userID: userID)
            return dtos.map { dto in
                let favorite = favoritesStorage.isFavorite(id: String(dto.id))
                return Post(dto: dto, favorite: favorite)
            }
        } catch let apiError as APIError {
            throw RepositoryError.apiError(error: apiError)
        } catch {
            throw RepositoryError.unknown(error: error)
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
