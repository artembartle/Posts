// Developed by Artem Bartle

import Foundation

class PostViewModel {
    fileprivate let post: Post
    
    let title: String
    let body: String
    let favorite: Bool
    
    var favoriteAction: ((_ post: Post) -> ())?
    
    init(post: Post) {
        self.post = post
        self.title = post.title
        self.body = post.body
        self.favorite = post.favorite
    }
    
    func triggerFavoriteAction() {
        favoriteAction?(post)
    }
}

extension PostViewModel: Identifiable {
    var id: String {
        post.id
    }
}
