// Developed by Artem Bartle

import Foundation

struct PostDTO: Equatable {
    let id: String
    let title: String
    let body: String
}

extension PostDTO {
    static let stub = Self(
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

enum APIError: Error, Equatable {
    case parsing
    case network
    case incorrectUserId
    case unknown(description: String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .parsing:
            return NSLocalizedString("There is no user with such ID.", comment: "")
            
        case .network:
            return NSLocalizedString("A network error has occurred.", comment: "")
            
        case .incorrectUserId:
            return NSLocalizedString("Invalid User ID.", comment: "")
            
        case .unknown(let decription):
            return decription
        }
    }
}

protocol APIClient {
    func loadPosts(userID: String) async throws -> [PostDTO]
}
