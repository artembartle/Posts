// Developed by Artem Bartle

import SwiftUI
import Factory

struct FeedView: View {
    typealias ViewModel = FeedViewModel
    typealias VMState = FeedViewModel.State
    
    @ObservedObject var viewModel = Container.feedViewModel()
    
    var body: some View {
        VStack {
            if !viewModel.state.isEmpty {
                List {
                    ForEach(viewModel.postsVMs) {
                        PostView(viewModel:$0)
                    }
                }
            } else {
                Spacer()
                Text("There's no posts so far!")
            }
            
            Spacer()
            
            Picker("", selection: viewModel.selectedFilter) {
                Text("All").tag(ViewModel.Filter.all)
                Text("Favorites").tag(ViewModel.Filter.favorites)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .task {
            await viewModel.load()
        }
    }
}


struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = Container.apiClient.register {
            let dtos = (0..<10).map { i in
                PostDTO.stub(id: i)
            }
            let client = MockAPIClient()
            client.response = .success(dtos)
            client.response = .failure(.incorrectUserId)
            return client
        }
        
        let allPosts = [Post.stub(favorite: false), Post.stub(favorite: true), Post.stub(favorite: false)]
        let _ = Container.feedViewModel.register {
//            let state = FeedViewModel.State.initial
            let state = FeedViewModel.State.loaded(posts: allPosts)
            let vm = FeedViewModel(state: state)
            return vm
        }
        
        FeedView()
    }
}
