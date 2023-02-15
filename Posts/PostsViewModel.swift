// Developed by Artem Bartle

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    enum State: Equatable {
        case initial
        case fetching(userID: String)
        case posts(userID: String, posts: [Post])
        case failure(userID: String, error: String)
    }
    
    private let api: APIClient
    
    @Published var state: State = .initial
    
    init(api: APIClient) {
        self.api = api
    }
    
    func login(userId: String) async {
        state = .fetching(userID: userId)
        
        do {
            let posts = try await api.loadPosts(userId: userId)
            state = .posts(userID: userId, posts: posts)
        }
        catch {
            state = .failure(userID: userId, error: error.localizedDescription)
        }
    }
}
