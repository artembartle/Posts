// Developed by Artem Bartle

import Foundation

class PostViewModel: Identifiable {
    private let post: Post
    private let favoriteAction: ((_ post: Post) -> ())?
    
    let title: String
    let body: String
    let favorite: Bool
    
    var id: String {
        post.id
    }
    
    init(post: Post, favoriteAction: ((_ post: Post) -> ())? = nil) {
        self.post = post
        self.title = post.title
        self.body = post.body
        self.favorite = post.favorite
        self.favoriteAction = favoriteAction
    }
    
    func triggerFavoriteAction() {
        favoriteAction?(post)
    }
}
