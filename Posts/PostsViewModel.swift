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
    
    @Published private(set) var state: State = .initial
    
    init(api: APIClient) {
        self.api = api
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
