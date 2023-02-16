// Developed by Artem Bartle

import SwiftUI

@main
struct PostsApp: App {
    
    @MainActor
    static var mockedViewModel: PostsViewModel {
        let apiClient = MockAPIClient()
        apiClient.response = .success([Post.mock])
        return PostsViewModel(api: apiClient)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PostsApp.mockedViewModel)
        }
    }
}
