// Developed by Artem Bartle

import SwiftUI

//extension FeedViewModel {
//    var isAlert: Binding<Bool> {
//        return Binding { [weak self] in
//            guard let login = self?.login else {
//                return false
//            }
//            
//            return login.alertIsDisplayed
//        } set: { [weak self] displayed in
//            self?.login?.alertIsDisplayed = displayed
//        }
//    }
//    
//    var selectedFilter: Binding<Filter> {
//        return Binding { [weak self] in
//            guard case let .posts(_, _, _, filter) = self?.state else {
//                return .all
//            }
//            
//            return filter
//        } set: { [weak self] newFilter in
//            self?.applyFilter(filter: newFilter)
//        }
//    }
//}
