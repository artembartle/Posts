// Developed by Artem Bartle

import Foundation

class MockAPIClient: APIClient {
    var response: Result<[Post], APIError>?
    
    func loadPosts(userID: String) async throws -> [Post] {
        guard let response = response else {
            return []
        }
        return try response.get()
    }
}

extension Post {
    static let mock = Self(
        id: UUID().uuidString,
        title: "Title",
        body: """
        suscipit nam nisi quo aperiam aut \
        asperiores eos fugit maiores voluptatibus quia \
        voluptatem quis ullam qui in alias quia est \
        consequatur magni mollitia accusamus ea nisi voluptate dicta
        """
    )
}
