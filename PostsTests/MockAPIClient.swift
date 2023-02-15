// Developed by Artem Bartle

class MockAPIClient: APIClient {
    
    var response: Result<[Post], APIError>!
    
    func loadPosts(userId: String) async throws -> [Post] {
        return try response.get()
    }
}
