// Developed by Artem Bartle

import XCTest
import Factory

@MainActor
final class LoginTests: XCTestCase {
    let userID = "1"
    var sut: LoginViewModel!
    var stateCollector: StateCollector<LoginViewModel.State>!
    var repository: MockRepository!
    
    override func setUpWithError() throws {
        Container.Registrations.push()
        Container.setupMocks()
        
        sut = Container.loginViewModel()
        sut.state.userID = userID
        
        repository = Container.postsRepository() as? MockRepository
        stateCollector = StateCollector(sut.$state)
    }
    
    override func tearDown() async throws {
        Container.Registrations.pop()
    }
    
    func testLogin() async {
        // Given ViewModel and repository with 5 posts
        let posts = (0..<5).map { _ in Post.stub() }
        repository.response = .success(posts)
                
        // When call login
        await sut.login()
        
        // Then collected states should be
        // initial -> fetching -> loggedIn
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial(userID: userID),
                .fetching(userID: userID),
                .loggedIn(userID: userID)
            ]
        )
    }
    
    func testLoginFailure() async {
        // Given viewModel and network-related error
        let error = RepositoryError.apiError(error: APIError.network)
        repository.response = .failure(error)

        // When call login
        await sut.login()

        // Then collected states should be
        // initial -> fetching -> failure
        XCTAssertEqual(
            stateCollector.collectedStates,
            [
                .initial(userID: userID),
                .fetching(userID: userID),
                .failure(error: error)
            ]
        )
    }

}
