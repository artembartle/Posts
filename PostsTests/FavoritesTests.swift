// Developed by Artem Bartle

import XCTest
import Factory

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
        // Given userID and favorite posts and non-favorite posts
        let userID = "1"
        let favorite = [Post(id: "1", title: "A", body: "", favorite: true)]
        let nonFavorite = [Post(id: "2", title: "B", body: "", favorite: false)]

        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite + nonFavorite))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
            
        // When
        sut.applyFilter(filter: .favorites)
        
        // Then collected states should be
        // posts(fav+nonFav, filter: .all) -> posts(fav, filter: .favorites)
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite + nonFavorite, filter: .all),
                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite, filter: .favorites)
            ]
        )
    }
    
    func testApplyAllPostsFilter() {
        // Given userID and favorite posts and non-favorite posts
        let userID = "1"
        let favorite = [Post(id: "1", title: "A", body: "", favorite: true)]
        let nonFavorite = [Post(id: "2", title: "B", body: "", favorite: false)]

        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: "1", posts: favorite + nonFavorite, displayed: favorite, filter: .favorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
            
        // When
        sut.applyFilter(filter: .all)
        
        // Then collected states should be
        // posts(displayed: favorite, filter: .favorites) -> posts(displayed: favorite + nonFavorite, filter: .all)
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite, filter: .favorites),
                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite + nonFavorite, filter: .all)
            ]
        )
    }
    
    func testAddToFavorites() {
        // Given userID and favorite posts and non-favorite posts
        let userID = "1"
        let favorite = [Post(id: "1", title: "A", body: "", favorite: true)]
        let nonFavoritePost = Post(id: "2", title: "B", body: "", favorite: false)

        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: userID, posts: favorite + [nonFavoritePost], displayed: favorite + [nonFavoritePost], filter: .all))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
                        
        // When make apply favorite action on nonFavorite post
        sut.applyFavoriteAction(post: nonFavoritePost)
        
        // Then collected states should be
        // posts(displayed: favorite + [nonFavoritePost], filter: .all) ->
        // posts(displayed: favorite + [newFavPost], filter: .all)
        var newFavPost = nonFavoritePost
        newFavPost.favorite = true
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .posts(userID: userID,
                       posts: favorite + [nonFavoritePost],
                       displayed: favorite + [nonFavoritePost],
                       filter: .all),
                .posts(userID: userID,
                       posts: favorite + [newFavPost],
                       displayed: favorite + [newFavPost],
                       filter: .all)
            ]
        )
    }
    
    func testRemoveFromFavorites() {
        // Given userID and favorite posts and non-favorite posts
        let userID = "1"
        let favoritePost = Post(id: "1", title: "A", body: "", favorite: true)
        let nonFavoritePosts = [Post(id: "2", title: "B", body: "", favorite: false)]

        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: userID,
                                        posts: [favoritePost] + nonFavoritePosts,
                                        displayed: [favoritePost] + nonFavoritePosts,
                                        filter: .all))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
                        
        // When make apply favorite action on favorite post
        sut.applyFavoriteAction(post: favoritePost)
        
        // Then collected states should be
        // posts(displayed: [favoritePost] + nonFavoritePosts, filter: .all) ->
        // posts(displayed: [newNonFavPost] + nonFavoritePosts, filter: .all)
        var newNonFavPost = favoritePost
        newNonFavPost.favorite = false
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .posts(userID: userID,
                       posts: [favoritePost] + nonFavoritePosts,
                       displayed: [favoritePost] + nonFavoritePosts,
                       filter: .all),
                .posts(userID: userID,
                       posts: [newNonFavPost] + nonFavoritePosts,
                       displayed: [newNonFavPost] + nonFavoritePosts,
                       filter: .all)
            ]
        )
    }
    
    func testRemoveFromFavoritesWhileFavFilterIsActive() {
        // Given userID and favorite posts and non-favorite posts
        let userID = "1"
        let favoritePost = Post(id: "1", title: "A", body: "", favorite: true)
        let nonFavoritePosts = [Post(id: "2", title: "B", body: "", favorite: false)]

        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: userID,
                                        posts: [favoritePost] + nonFavoritePosts,
                                        displayed: [favoritePost] + nonFavoritePosts,
                                        filter: .favorites))
        }
        let sut = Container.feedViewModel()
        let stateCollector = StateCollector(sut.$state)
                        
        // When make apply favorite action on favorite post
        sut.applyFavoriteAction(post: favoritePost)
        
        // Then collected states should be
        // posts(displayed: [favoritePost] + nonFavoritePosts, filter: .filter) ->
        // posts(displayed: [newNonFavPost] + nonFavoritePosts, filter: .favorites)
        var newNonFavPost = favoritePost
        newNonFavPost.favorite = false
        
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .posts(userID: userID,
                       posts: [favoritePost] + nonFavoritePosts,
                       displayed: [favoritePost] + nonFavoritePosts,
                       filter: .favorites),
                .posts(userID: userID,
                       posts: [newNonFavPost] + nonFavoritePosts,
                       displayed: [newNonFavPost] + nonFavoritePosts,
                       filter: .favorites)
            ]
        )
    }
}
