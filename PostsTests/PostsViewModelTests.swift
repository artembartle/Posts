// Developed by Artem Bartle

import XCTest
import Factory

extension Container {
    static func setupMocks() {
//        favoritesStorage = Factory<any FavoritesStorage<Post.ID>> { UserDefaultsFavorites<Post.ID>() }
        favoritesStorage.register {
            guard let userDefaults = UserDefaults(suiteName: #file) else {
                fatalError()
            }
            userDefaults.removePersistentDomain(forName: #file)
            return UserDefaultsFavorites<Post.ID>(userDefaults: userDefaults)
        }
//        myService.register { MockServiceN(4) }
//        sharedService.register { MockService2() }
    }
}

@MainActor
final class PostsViewModelTests: XCTestCase {
    var repository: MockRepository!
    var sut: PostsViewModel!
    var stateCollector: StateCollector<PostsViewModel.State>!
    
    override func setUpWithError() throws {
        Container.Registrations.push()
        Container.setupMocks()
        
        // Register MockRepository
        Container.postsRepository.register {
            MockRepository()
        }

        sut = Container.feedViewModel()
        stateCollector = StateCollector(sut.$state)
        repository = Container.postsRepository() as? MockRepository
    }
    
    override func tearDown() async throws {
        Container.Registrations.pop()
    }
    
    func testLogin() async throws {
        // Given userID and 5 posts
        let userID = "1"
        let posts = (0..<5).map { _ in Post.stub }
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
                .posts(userID: userID, posts: posts)
            ]
        )
    }
    
    func testLoginFailure() async throws {
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
