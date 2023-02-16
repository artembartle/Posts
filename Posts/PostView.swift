// Developed by Artem Bartle

import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    let id: String
    let title: String
    let body: String
    
    init(post: Post) {
        self.id = post.id
        self.title = post.title
        self.body = post.body
    }
}

struct PostView: View {
    typealias ViewModel = PostViewModel
    
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.title)
                Text(viewModel.body)
                    .font(.body)
            }
            
            HStack {
                Spacer()
                VStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "heart.fill")
                    }
                    .padding()
                    Spacer()
                }

            }

        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(viewModel: PostViewModel(post: Post.mock))
    }
}
