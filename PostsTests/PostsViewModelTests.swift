// Developed by Artem Bartle

import XCTest

@MainActor
final class PostsViewModelTests: XCTestCase {
    var client: MockAPIClient!
    var repository: PostsRepositoryImpl!
    var sut: PostsViewModel!
    var stateCollector: StateCollector<PostsViewModel.State>!
    
    override func setUpWithError() throws {
        client = MockAPIClient()
        sut = PostsViewModel(api: client)
        stateCollector = StateCollector(sut.$state)
    }
    
    func testLogin() async throws {
        // Given userID and 5 posts
        let userID = "1"
        let posts = (0..<5).map { _ in Post.mock }
        client.response = .success(posts)
        
        // When call login
        await sut.login(userID: userID)
        
        // Then collected states should be
        // initial -> fetching -> posts
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .fetching(userID: userID),
                .posts(userID: userID, posts: posts)
            ]
        )
    }
    
    func testLoginFailure() async throws {
        // Given userID and networking related error
        let userID = "1"
        let error = APIError.network
        client.response = .failure(.network)
        
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
