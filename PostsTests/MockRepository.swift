// Developed by Artem Bartle

import Foundation

class MockRepository: PostsRepository {
    var response: Result<[Post], RepositoryError>?
    
    func login(userID: String) async throws {
        guard let response = response else {
            return
        }
        let _ = try response.get()
    }
    
    func getPosts() async throws -> [Post] {
        guard let response = response else {
            return []
        }
        return try response.get()
    }

    func applyFavoriteAction(post: Post) -> Post {
        var updatedPost = post
        updatedPost.favorite = !updatedPost.favorite
        return updatedPost
    }
}
