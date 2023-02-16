// Developed by Artem Bartle

import SwiftUI

extension PostsViewModel {
    var isAlertPresented: Binding<Bool> {
        return Binding { [weak self] in
            if case .failure = self?.state {
                return true
            } else {
                return false
            }
        } set: { _ in }
    }
    
    var alertTitle: String? {
        guard case let .failure(_, error) = state else {
            return nil
        }
        return error
    }
}
