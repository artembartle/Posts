// Developed by Artem Bartle

import Foundation

class MockAPIClient: APIClient {
    var response: Result<[PostDTO], APIError>?
    
    func loadPosts(userID: String) async throws -> [PostDTO] {
        guard let response = response else {
            return []
        }
        return try response.get()
    }
}
