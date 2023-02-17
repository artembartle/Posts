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
    static var mockedViewModel: PostsViewModel {
        let dtos = (0..<10).map { i in
            PostDTO(id: String(i), title: "Title", body: PostDTO.mock.body)
        }
        let posts = dtos.map { Post(dto: $0, favorite: true) }
        let client = MockAPIClient()
        client.response = .success(dtos)
        let repository = PostsRepositoryImpl(api: client)
        return PostsViewModel(state: .posts(userID: "1", posts: posts),
                              repository: repository)
    }
    
    static var previews: some View {
        ContentView(viewModel: mockedViewModel)
    }
}
