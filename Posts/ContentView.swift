// Developed by Artem Bartle

import SwiftUI

struct ContentView: View {
    typealias ViewModel = PostsViewModel
    typealias VMState = PostsViewModel.State
    
    @ObservedObject var viewModel: ViewModel
    @State var userID: String = ""
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                if case VMState.initial = viewModel.state {
                    loginView
                }
                
                if case VMState.fetching = viewModel.state {
                    fetching
                }
            }
            
            if case VMState.posts = viewModel.state {
                List {
                    ForEach(viewModel.postsVMs, id: \.id) { vm in
                        PostView(viewModel: vm)
                    }
                }
            }
        }
        .alert(
            "Error",
            isPresented: viewModel.isAlertPresented,
            presenting: viewModel.alertTitle) {
                Text($0)
            }
    }
}

private extension ContentView {
    
    var loginView: some View {
        VStack {
            TextField("UserID", text: $userID)
                .background {
                    Color.blue
                }
            
            Button("Login") {
                Task {
                    await viewModel.login(userID: userID)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background {
                Color.blue
            }
        }
        .padding()
    }
    
    var fetching: some View {
        ZStack {
            Color.gray
            ProgressView()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var mockedViewModel: PostsViewModel {
        let apiClient = MockAPIClient()
                apiClient.response = .success([Post.mock, Post.mock, Post.mock])
//        apiClient.response = .failure(.network)
        return PostsViewModel(api: apiClient,
                              state: .posts(userID: "1", posts: [Post.mock]))
    }
    
    static var previews: some View {
        ContentView(viewModel: mockedViewModel)
    }
}
