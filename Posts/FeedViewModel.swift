// Developed by Artem Bartle

import Foundation
import SwiftUI
import Factory

class FeedViewModel: ObservableObject {
    enum Filter: Int, Equatable {
        case all = 0
        case favorites = 1
    }
    
    struct State: Equatable {
        var all: [Post] = []
        var displayed: [Post] = []
        var filter: Filter = .all
        var isEmpty = true
        
        static let initial = Self(
        )
        
        static func loaded(posts: [Post]) -> Self {
            Self(
                all: posts, displayed: posts, filter: .all, isEmpty: posts.isEmpty
            )
        }
        
        static func loaded(posts: [Post], filter: Filter) -> Self {
            let displayed = (filter == .all) ? posts : posts.filter { $0.favorite }
            
            return Self(
                all: posts,
                displayed: displayed,
                filter: filter,
                isEmpty: displayed.isEmpty
            )
        }
        
        static func updated(state: Self, updated: Post) -> Self {
            var newPosts = state.all
            if let index = newPosts.firstIndex(where: { $0.id == updated.id }) {
                newPosts[index] = updated
            }
            return loaded(posts: newPosts, filter: state.filter)

        }
    }
    
    @Injected(Container.postsRepository) private var repository
    @Published var state: State = .initial
    
    init(state: State = .initial) {
        self.state = state
    }
    
    @MainActor
    func load() async {
        do {
            let posts = try await repository.getPosts()
            state = .loaded(posts: posts)
        } catch let repoError as RepositoryError {
            //            state = .failure(error: repoError)
        } catch {
            print("Unexpected error type after getPost() call")
            //            state = .failure(error: error)
        }
    }
    
    func applyFilter(filter: Filter) {
        state = .loaded(posts: state.all, filter: filter)
    }
    
    func applyFavoriteAction(post: Post) {
        let updatedPost = repository.applyFavoriteAction(post: post)
        state = .updated(state: state, updated: updatedPost)
    }
    
    var postsVMs: [PostViewModel] {
        return state.displayed.map { post in
            PostViewModel(post: post) { [weak self] in
                self?.applyFavoriteAction(post: $0)
            }
        }
    }
}
