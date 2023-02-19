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
    }
        
    @Injected(Container.postsRepository) private var repository
    @Published var state: State = .initial
//    var postsVMs: [PostViewModel] = []
    
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
        state.filter = filter
        
        let filteredPosts = filteredPosts(posts: state.all, filter: filter)
        state.displayed = filteredPosts
    }
    
    func applyFavoriteAction(post: Post) {
        let updatedPost = repository.applyFavoriteAction(post: post)
        if let index = state.all.firstIndex(of: post) {
            state.all[index] = updatedPost
        }
        
        if let index = state.displayed.firstIndex(of: post) {
            state.displayed[index] = updatedPost
        }
        
//        state = .posts(userID: userID, posts: posts, displayed: displayed, filter: filter)
    }
    
//    private func reloadPostsVMs() {
//        let filter = state.filter
//        postsVMs = state.displayed
//            .filter { post in
//                if filter == .favorites {
//                    return post.favorite
//                }
//                return true
//            }
//            .map { post in
//                let vm = PostViewModel(post: post)
//                vm.favoriteAction = { [weak self] p in
//                    self?.applyFavoriteAction(post: p)
//                }
//                return vm
//            }
//    }
    
    var postsVMs: [PostViewModel] {
//        guard case let .posts(_, _, displayed, _) = state else {
//            return []
//        }
        let filter = state.filter
        return state.displayed
//            .filter { post in
//                if filter == .favorites {
//                    return post.favorite
//                }
//                return true
//            }
            .map { post in
                let vm = PostViewModel(post: post)
                vm.favoriteAction = { [weak self] p in
                    self?.applyFavoriteAction(post: p)
                }
                return vm
            }
    }
    
    private func filteredPosts(posts: [Post], filter: Filter) -> [Post] {
        posts.filter { post in
            if filter == .favorites {
                return post.favorite
            }
            return true
        }
    }
    
    var selectedFilter: Binding<Filter> {
        return Binding { [weak self] in
            return self?.state.filter ?? .all
        } set: { [weak self] newFilter in
            self?.applyFilter(filter: newFilter)
        }
    }

}
