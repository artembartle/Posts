// Developed by Artem Bartle

import Foundation

class MockAPIClient: APIClient {
    
    var response: Result<[Post], APIError>!
    
    func loadPosts(userId: String) async throws -> [Post] {
        return []
    }
}
