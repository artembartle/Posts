// Developed by Artem Bartle

import Foundation

struct Post: Equatable {
    let id: String
    let title: String
    let body: String
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
    func loadPosts(userId: String) async throws -> [Post]
}
