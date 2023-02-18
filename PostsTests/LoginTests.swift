// Developed by Artem Bartle

import XCTest
import Factory

@MainActor
final class LoginTests: XCTestCase {
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
    
    func testLogin() async {
        // Given userID and 5 posts
        let userID = "1"
        let posts = (0..<5).map { _ in Post.stub() }
        repository.response = .success(posts)
                
        // When call login
        await sut.login(userID: userID)
        
        // Then collected states should be
        // initial -> fetching -> posts
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .fetching(userID: userID),
                .posts(userID: userID, posts: posts, displayed: posts)
            ]
        )
    }
    
    func testLoginFailure() async {
        // Given userID and networking related error
        let userID = "1"
        let error = APIError.network
        repository.response = .failure(.network)

        // When call login
        await sut.login(userID: userID)

        // Then collected states should be
        // initial -> fetching -> failure
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .fetching(userID: userID),
                .failure(userID: userID, error: error.localizedDescription)
            ]
        )
    }

}
