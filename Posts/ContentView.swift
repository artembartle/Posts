// Developed by Artem Bartle

import SwiftUI
import Factory

struct ContentView: View {
    typealias ViewModel = FeedViewModel
    typealias VMState = FeedViewModel.State
    
    @ObservedObject var viewModel = Container.feedViewModel()
    @State var userID: String = ""

    var body: some View {
        switch viewModel.state {
        case .initial:
            loginView
            
        case .fetching:
            ZStack {
                loginView
                fetching
            }
        case .posts:
            VStack {
                List {
                    ForEach(viewModel.postsVMs) { vm in
                        PostView(viewModel: vm)
                    }
                }
                
                Picker("", selection: viewModel.selectedFilter) {
                    Text("All").tag(ViewModel.Filter.all)
                    Text("Favorites").tag(ViewModel.Filter.favorites)
                }
                .pickerStyle(.segmented)
                .padding()
                
            }
        case .failure:
            loginView
                .alert("Error",
                       isPresented: viewModel.isAlertPresented,
                       presenting: viewModel.alertTitle) {
                    Text($0)
                }
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
    static var previews: some View {
        let _ = Container.apiClient.register {
            let dtos = (0..<10).map { i in
                PostDTO(id: String(i), title: "Title", body: PostDTO.stub.body)
            }
            let client = MockAPIClient()
            client.response = .success(dtos)
            return client
        }
        
        let _ = Container.feedViewModel.register {
            FeedViewModel(state: .posts(userID: "1", posts: [Post.stub]))
        }
        
        ContentView()
    }
}
