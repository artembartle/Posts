// Developed by Artem Bartle

import SwiftUI

@main
struct PostsApp: App {
    
    @MainActor
    static var mockedViewModel: PostsViewModel {
        let apiClient = MockAPIClient()
        apiClient.response = .success( (0..<10).map { Post(id: String($0), title: "Title", body: "Body") } )
        return PostsViewModel(api: apiClient)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PostsApp.mockedViewModel)
        }
    }
}
