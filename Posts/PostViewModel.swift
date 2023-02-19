// Developed by Artem Bartle

import Foundation

class PostViewModel {
    fileprivate let post: Post
    
    let title: String
    let body: String
    let favorite: Bool
    
    private let favoriteAction: ((_ post: Post) -> ())?
    
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

extension PostViewModel: Identifiable {
    var id: String {
        post.id
    }
}
