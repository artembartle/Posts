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
        
        Container.postsRepository.register {
            MockRepository()
        }
        
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
                
        // When call load
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
//        TODO: Add fetching and failure states to FeedVM
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
//                .failure(error: error)
            ]
        )
    }
}
