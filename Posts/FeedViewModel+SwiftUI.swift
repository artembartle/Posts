// Developed by Artem Bartle

import SwiftUI

extension FeedViewModel {
    var selectedFilter: Binding<Filter> {
        return Binding { [weak self] in
            return self?.state.filter ?? .all
        } set: { [weak self] newFilter in
            self?.applyFilter(filter: newFilter)
        }
    }
}
