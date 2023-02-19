// Developed by Artem Bartle

import XCTest
import Factory

@MainActor
final class FeedTests: XCTestCase {
    var sut: FeedViewModel!
    var stateCollector: StateCollector<FeedViewModel.State>!
    var repository: MockRepository!
    
    override func setUpWithError() throws {
        Container.Registrations.push()
        Container.setupMocks()
        
        sut = Container.feedViewModel()
        
        repository = Container.postsRepository() as? MockRepository
        stateCollector = StateCollector(sut.$state)
    }

    override func tearDown() async throws {
        Container.Registrations.pop()
    }
    
    func testLoadFeed() async throws {
        // Given ViewModel and repository with 5 posts
        let posts = (0..<5).map { _ in Post.stub() }
        repository.response = .success(posts)
                
        // When call login
        await sut.load()
        
        // Then collected states should be
        // initial -> loaded
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .loaded(posts: posts)
            ]
        )
    }
    
    func testLoadFeedFailure() async throws {
        // Given viewModel and network-related error
        let error = RepositoryError.apiError(error: APIError.network)
        repository.response = .failure(error)

        // When call login
        await sut.load()

        // Then collected states should be
        // initial -> fetching -> failure
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
//                .failure(error: error)
            ]
        )
    }
    
//    func testApplyOnlyFavoritesFilter() {
//        // Given userID and favorite posts and non-favorite posts
//        let userID = "1"
//        let favorite = [Post.stub(favorite: true)]
//        let nonFavorite = [Post.stub(favorite: false)]
//
//        let _ = Container.feedViewModel.register {
//            FeedViewModel(state: .initial)
//        }
//        let sut = Container.feedViewModel()
//        let stateCollector = StateCollector(sut.$state)
//
//        // When
//        sut.applyFilter(filter: .favorites)
//
//        // Then collected states should be
//        // posts(fav+nonFav, filter: .all) -> posts(fav, filter: .favorites)
//        XCTAssertEqual(
//            stateCollector.collectedStates,
//            [
//                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite + nonFavorite, filter: .all),
//                .posts(userID: userID, posts: favorite + nonFavorite, displayed: favorite, filter: .favorites)
//            ]
//        )
//    }
}
