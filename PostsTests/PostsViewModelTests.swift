// Developed by Artem Bartle

import XCTest

@MainActor
final class PostsViewModelTests: XCTestCase {
    var client: MockAPIClient!
    var sut: PostsViewModel!
    var stateCollector: StateCollector<PostsViewModel.State>!
    
    override func setUpWithError() throws {
        client = MockAPIClient()
        sut = PostsViewModel(api: client)
        stateCollector = StateCollector(sut.$state)
    }
    
    func testLogin() async throws {
        // Given userId and 5 posts
        let userId = "1"
        let posts = (0..<5).map { _ in Post.mock }
        client.response = .success(posts)
        
        // When call login
        await sut.login(userId: userId)
        
        // Then collected states should be
        // initial -> fetching -> posts
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .fetching(userID: userId),
                .posts(userID: userId, posts: posts)
            ]
        )
    }
    
    func testLoginFailure() async throws {
        // Given userId and networking related error
        let userId = "1"
        let error = APIError.network
        client.response = .failure(.network)
        
        // When call login
        await sut.login(userId: userId)
        
        // Then collected states should be
        // initial -> fetching -> failure
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial,
                .fetching(userID: userId),
                .failure(userID: userId, error: error.localizedDescription)
            ]
        )
    }
}

extension Post {
    static let mock = Self(
        id: UUID().uuidString,
        title: "Title",
        body: """
        suscipit nam nisi quo aperiam aut \
        asperiores eos fugit maiores voluptatibus quia \
        voluptatem quis ullam qui in alias quia est \
        consequatur magni mollitia accusamus ea nisi voluptate dicta
        """
    )
}
