// Developed by Artem Bartle

import SwiftUI

extension PostsViewModel {
    var isAlertPresented: Binding<Bool> {
        return Binding { [weak self] in
            guard case .failure = self?.state else {
                return false
            }
            
            return true
        } set: { _ in }
    }
    
    var selectedFilter: Binding<Filter> {
        return Binding { [weak self] in
            guard case let .posts(_, _, filter) = self?.state else {
                return .all
            }
            
            return filter
        } set: { [weak self] newFilter in
            guard case .posts = self?.state else {
                return
            }
            
            self?.applyFilter(filter: newFilter)
        }
    }
}
