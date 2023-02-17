// Developed by Artem Bartle

import SwiftUI

@main
struct PostsApp: App {
    @MainActor
    static var mockedViewModel: PostsViewModel {
        let posts = (0..<10).map { PostDTO(id: String($0), title: "Title", body: PostDTO.mock.body) }
        let client = MockAPIClient()
        client.response = .success(posts)
        let repository = PostsRepositoryImpl(api: client)
        return PostsViewModel(repository: repository)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PostsApp.mockedViewModel)
        }
    }
}
