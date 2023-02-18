// Developed by Artem Bartle

import SwiftUI

@main
struct PostsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//extension Resolver: ResolverRegistering {
//    public static func registerAllServices() {
//        register { UserDefaultsFavorites<String>() }
//            .implements((any FavoritesStorage<String>).self)
//        
//        register { MockAPIClient() }
//            .resolveProperties { (_, client) in
//                let posts = (0..<10).map { PostDTO(id: String($0), title: "Title", body: PostDTO.mock.body) }
//                client.response = .success(posts)
//            }
//            .implements(APIClient.self)
//        
//        register { PostsRepositoryImpl(favoritesStorage: resolve(), api: resolve()) }
//            .implements(PostsRepository.self)
//            .scope(.application)
//        
//        register { FeedViewModel(repository: resolve()) }
//    }
//}
