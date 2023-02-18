// Developed by Artem Bartle

import Foundation

struct PostDTO: Equatable {
    let id: Int
    let title: String
    let body: String
}

extension PostDTO {
    static func stub(id: Int = .random(in: 0..<100)) -> Self {
        Self(
            id: id,
            title: "Title",
            body: """
            suscipit nam nisi quo aperiam aut \
            asperiores eos fugit maiores voluptatibus quia \
            voluptatem quis ullam qui in alias quia est \
            consequatur magni mollitia accusamus ea nisi voluptate dicta
            """
        )
    }
}

extension PostDTO: Decodable {
}

enum APIError: Equatable {
    case parsing
    case network
    case incorrectUserId
    case unknown(description: String)
}

extension APIError: LocalizedError {
    var localizedDescription: String? {
        switch self {
        case .parsing:
            return NSLocalizedString("A decoding error has occured.", comment: "")
            
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

class LiveAPIClient : APIClient {
    static let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!

    let urlSession = URLSession.shared
        
    func loadPosts(userID: String) async throws -> [PostDTO] {
        guard let _ = UInt64(userID) else {
            throw APIError.incorrectUserId
        }
        
        let url = postsURL(userID: userID)
        return try await load(with: url)
    }
    
    private func postsURL(userID: String) -> URL? {
        var urlComponents = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
        urlComponents?.path = "/posts"
        urlComponents?.queryItems = [URLQueryItem(name: "userId", value: userID)]
        return urlComponents?.url
    }
    
    private func commentsURL(postID: String) -> URL? {
        var urlComponents = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
        urlComponents?.path = "/comments"
        urlComponents?.queryItems = [URLQueryItem(name: "postId", value: postID)]
        return urlComponents?.url
    }
    
    private func load<T>(with url: URL?) async throws -> T where T: Decodable {
        guard let url = url else {
            throw APIError.network
        }
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch is URLError {
            throw APIError.network
        } catch is DecodingError {
            throw APIError.parsing
        } catch {
            throw APIError.unknown(description: error.localizedDescription)
        }
    }
}
