// Developed by Artem Bartle

import Foundation

class MockRepository: PostsRepository {
    var response: Result<[Post], APIError>?
    
    func getPosts(userID: String) async throws -> [Post] {
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
