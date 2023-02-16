// Developed by Artem Bartle

import Foundation
import Combine

@MainActor
class PostsViewModel: ObservableObject {
    enum State: Equatable {
        case initial
        case fetching(userID: String)
        case posts(userID: String, posts: [Post])
        case failure(userID: String, error: String)
    }
    
    private let api: APIClient
//    private var posts: [Post] = []
    
    @Published private(set) var state: State = .initial
    
    init(api: APIClient, state: State = .initial) {
        self.api = api
        self.state = state
    }
    
    func login(userID: String) async {
        state = .fetching(userID: userID)
        
        do {
            let posts = try await api.loadPosts(userID: userID)
            state = .posts(userID: userID, posts: posts)
        }
        catch {
            state = .failure(userID: userID, error: error.localizedDescription)
        }
    }
}

extension PostsViewModel {
    var alertTitle: String? {
        guard case let .failure(_, error) = state else {
            return nil
        }
        return error
    }
    
    var postsVMs: [PostViewModel] {
        guard case let .posts(_, posts) = state else {
            return []
        }
        
        return posts.map { PostViewModel(post:$0) }
    }
}
