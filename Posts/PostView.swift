// Developed by Artem Bartle

import SwiftUI

struct PostView: View {
    typealias ViewModel = PostViewModel
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.title)
                Text(viewModel.body)
                    .font(.body)
            }
            
            Spacer()

            VStack {
                Spacer()
                
                Button {
                    viewModel.triggerFavoriteAction()
                } label: {
                    Image(systemName: viewModel.favorite ? "heart.fill" : "heart")
                }
                .padding()
                
                Spacer()
            }
        }
        
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(viewModel: PostViewModel(post: Post.stub()))
    }
}
