// Developed by Artem Bartle

import XCTest
import Factory

extension FeedViewModel.State {
    static func loaded(posts: [Post], displayed: [Post], filter: FeedViewModel.Filter) -> Self {
        return Self(
            all: posts,
            displayed: displayed,
            filter: filter,
            isEmpty: displayed.isEmpty
        )
    }
}

@MainActor
final class FavoritesTests: XCTestCase {
    override func setUpWithError() throws {
        Container.Registrations.push()
        Container.setupMocks()
    }
    
    override func tearDown() async throws {
        Container.Registrations.pop()
    }
    
    func testApplyOnlyFavoritesFilter() {
        // Given ViewModel and favorite posts and non-favorite posts
        let favorites = [Post.stub(favorite: true)]
        let nonFavorites = [Post.stub(favorite: false)]
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .loaded(posts: favorites + nonFavorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
            
        // When apply favorites filter
        sut.applyFilter(filter: .favorites)
        
        // Then collected states should be
        // loaded(..., displayed: favorites + nonFavorites, filter: .all) ->
        // loaded(..., displayed: favorites, filter: .favorites)
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .loaded(posts: favorites + nonFavorites, displayed: favorites + nonFavorites, filter: .all),
                .loaded(posts: favorites + nonFavorites, displayed: favorites, filter: .favorites)
            ]
        )
    }
    
    func testApplyAllPostsFilter() {
        // Given ViewModel and favorite posts and non-favorite posts
        let favorites = [Post.stub(favorite: true)]
        let nonFavorites = [Post.stub(favorite: false)]
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .loaded(posts: favorites + nonFavorites, displayed: favorites, filter: .favorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)

        // When apply .all filter
        sut.applyFilter(filter: .all)

        // Then collected states should be
        // posts(..., displayed: favorite + nonFavorite, filter: .all) ->
        // posts(..., displayed: favorite, filter: .favorites)
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .loaded(posts: favorites + nonFavorites, displayed: favorites, filter: .favorites),
                .loaded(posts: favorites + nonFavorites, displayed: favorites + nonFavorites, filter: .all)
            ]
        )
    }

    func testAddToFavorites() {
        // Given ViewModel and favorite posts and non-favorite posts
        let favorites = [Post.stub(favorite: true)]
        let nonFavoritePost = Post.stub(favorite: false)
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .loaded(posts: favorites + [nonFavoritePost]))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)

        // When apply favorite action on non-favorite post
        sut.applyFavoriteAction(post: nonFavoritePost)

        // Then collected states should be
        // .loaded(posts: favorites + [nonFavoritePost], filter: .all),
        // .loaded(posts: favorites + [newFavPost], filter: .all)
        var newFavPost = nonFavoritePost
        newFavPost.favorite = true
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .loaded(posts: favorites + [nonFavoritePost], filter: .all),
                .loaded(posts: favorites + [newFavPost], filter: .all)
            ]
        )
    }

    func testRemoveFromFavorites() {
        // Given ViewModel and favorite posts and non-favorite posts
        let favoritePost = Post.stub(favorite: true)
        let nonFavorites = [Post.stub(favorite: false)]
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .loaded(posts: [favoritePost] + nonFavorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)

        // When apply favorite action on favorite post
        sut.applyFavoriteAction(post: favoritePost)

        // Then collected states should be
        // .loaded(posts: [favoritePost] + nonFavorites, filter: .all) ->
        // .loaded(posts: [newNonFavPost] + nonFavorites, filter: .all)
        var newNonFavPost = favoritePost
        newNonFavPost.favorite = false
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .loaded(posts: [favoritePost] + nonFavorites, filter: .all),
                .loaded(posts: [newNonFavPost] + nonFavorites, filter: .all)
            ]
        )
    }

    func testRemoveFromFavoritesWhileFavFilterIsActive() {
        // Given ViewModel and favorite posts and non-favorite posts
        let favoritePost = Post.stub(favorite: true)
        let nonFavorites = [Post.stub(favorite: false)]
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .loaded(posts: [favoritePost] + nonFavorites, filter: .favorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)

        // When apply favorite action on favorite post
        sut.applyFavoriteAction(post: favoritePost)

        // Then collected states should be
        // .loaded(posts: [favoritePost] + nonFavorites, displayed: [favoritePost], filter: .favorites) ->
        // .loaded(posts: [newNonFavPost] + nonFavorites, displayed: [], filter: .favorites)
        var newNonFavPost = favoritePost
        newNonFavPost.favorite = false
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .loaded(posts: [favoritePost] + nonFavorites, displayed: [favoritePost], filter: .favorites),
                .loaded(posts: [newNonFavPost] + nonFavorites, displayed: [], filter: .favorites)
            ]
        )
    }
}
