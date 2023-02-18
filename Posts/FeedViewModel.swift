// Developed by Artem Bartle

import Foundation
import Factory

class FeedViewModel: ObservableObject {
    enum Filter: Int, Equatable {
        case all = 0
        case favorites = 1
    }
    
    enum State: Equatable {
        case initial
        case fetching(userID: String)
        case posts(userID: String, posts: [Post], displayed: [Post], filter: Filter = .all)
        case failure(userID: String, error: String?)
    }
    
    @Injected(Container.postsRepository) private var repository
    @Published private(set) var state: State = .initial
    @Published var isAlertPresented = false
    
    init(state: State = .initial) {
        self.state = state
    }
    
    @MainActor
    func login(userID: String) async {
        state = .fetching(userID: userID)
        
        do {
            let posts = try await repository.getPosts(userID: userID)
            state = .posts(userID: userID, posts: posts, displayed: posts, filter: .all)
        } catch let localizedError as RepositoryError {
            state = .failure(userID: userID, error: localizedError.localizedDescription)
            isAlertPresented = true
        } catch {
            print("Unexpected error type after getPost() call")
            state = .failure(userID: userID, error: error.localizedDescription)
            isAlertPresented = true
        }
    }
    
    func applyFilter(filter: Filter) {
        guard case let .posts(userID, posts, _, _) = state else {
            return
        }
        
        let filteredPosts = filteredPosts(posts: posts, filter: filter)
        state = .posts(userID: userID, posts: posts, displayed: filteredPosts, filter: filter)
    }
    
    func applyFavoriteAction(post: Post) {
        guard case .posts(let userID, var posts, var displayed, let filter) = state else {
            return
        }

        let updatedPost = repository.applyFavoriteAction(post: post)
        if let index = posts.firstIndex(of: post) {
            posts[index] = updatedPost
        }
        
        if let index = displayed.firstIndex(of: post) {
            displayed[index] = updatedPost
        }
        
        state = .posts(userID: userID, posts: posts, displayed: displayed, filter: filter)
    }
    
    private func filteredPosts(posts: [Post], filter: Filter) -> [Post] {
        posts.filter { post in
            if filter == .favorites {
                return post.favorite
            }
            return true
        }
    }
}

extension FeedViewModel {
    var alertTitle: String? {
        guard case let .failure(_, error) = state else {
            return nil
        }
        return error
    }
    
    var postsVMs: [PostViewModel] {
        guard case let .posts(_, _, displayed, _) = state else {
            return []
        }
        
        return displayed
            .map { post in
                let vm = PostViewModel(post: post)
                vm.favoriteAction = { [weak self] p in
                    self?.applyFavoriteAction(post: p)
                }
                return vm
            }
    }
}
