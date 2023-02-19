// Developed by Artem Bartle

import XCTest
import Factory

final class PostsRepositoryTests: XCTestCase {
    var sut: PostsRepositoryImpl!
    var mockFavoritesStorage: MockFavoritesStorage<Post.ID>!
    
    override func setUp() {
        super.setUp()
        
        Container.Registrations.push()
        Container.setupMocks()
        
        Container.favoritesStorage.register {
            MockFavoritesStorage()
        }
        
        Container.postsRepository.register {
            PostsRepositoryImpl()
        }
        
        sut = Container.postsRepository() as? PostsRepositoryImpl
        mockFavoritesStorage = Container.favoritesStorage() as? MockFavoritesStorage<Post.ID>
    }

    override func tearDown() {
        super.tearDown()
        
        Container.Registrations.pop()
    }

    func testAddToFavorites() {
        // Given Repository and non-favorite post
        let nonFavoritePost = Post.stub(favorite: false)
            
        // When make it favorite
        let updated = sut.applyFavoriteAction(post: nonFavoritePost)
        
        // Then returned value should be the same as nonFavoritePost but favorite == true
        // And nonFavoritePost's id should be added to favorite storage
        var newFavPost = nonFavoritePost
        newFavPost.favorite = true
        
        XCTAssertEqual(
            updated, newFavPost
        )
        
        XCTAssertEqual(
            mockFavoritesStorage.favorites, Set([newFavPost.id])
        )
    }

    func testRemoveFavorites() {
        // Given Repository and non-favorite post
        // And FavoriteStorage containing the id of favorite post
        let favoritePost = Post.stub(favorite: true)
        mockFavoritesStorage = Container.favoritesStorage() as? MockFavoritesStorage<Post.ID>
        mockFavoritesStorage.favorites = Set([favoritePost.id])
            
        // When make it non-favorite
        let updated = sut.applyFavoriteAction(post: favoritePost)
        
        // Then returned value should be the same as favoritePost but favorite == false
        // And favoritePost's id should be removed from favorite storage
        var newNonFavPost = favoritePost
        newNonFavPost.favorite = false
        
        XCTAssertEqual(
            updated, newNonFavPost
        )
        
        XCTAssertEqual(
            mockFavoritesStorage.favorites, Set([])
        )
    }
}
