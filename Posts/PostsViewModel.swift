// Developed by Artem Bartle

import Foundation
import Factory

class PostsViewModel: ObservableObject {
    enum Filter: Int, Equatable {
        case all = 0
        case favorites = 1
    }
    
    enum State: Equatable {
        case initial
        case fetching(userID: String)
        case posts(userID: String, posts: [Post], filter: Filter = .all)
        case failure(userID: String, error: String)
    }
    
    @Injected(Container.postsRepository) private var repository

    @Published private(set) var state: State = .initial
    
    init(state: State = .initial) {
        self.state = state
    }
    
    @MainActor
    func login(userID: String) async {
        state = .fetching(userID: userID)
        
        do {
            let posts = try await repository.getPosts(userID: userID)
            state = .posts(userID: userID, posts: posts, filter: .all)
        }
        catch {
            state = .failure(userID: userID, error: error.localizedDescription)
        }
    }
    
    func applyFilter(filter: Filter) {
        guard case let .posts(userID, posts, _) = state else {
            return
        }
        
        state = .posts(userID: userID, posts: posts, filter: filter)
    }
    
    func favoriteAction(post: Post) {
        guard case .posts(let userID, var posts, let filter) = state else {
            return
        }

        let updatedPost = repository.applyFavoriteAction(post: post)
        if let index = posts.firstIndex(of: post) {
            posts[index] = updatedPost
        }
        state = .posts(userID: userID, posts: posts, filter: filter)
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
        guard case let .posts(_, posts, filter) = state else {
            return []
        }
        
        return posts
            .filter { post in
                if filter == .favorites {
                    return post.favorite
                }
                return true
            }
            .map { post in
                let vm = PostViewModel(post: post)
                vm.favoriteAction = { [weak self] p in
                    self?.favoriteAction(post: p)
                }
                return vm
            }
    }
}
