// Developed by Artem Bartle

import Foundation
import Factory

class LoginViewModel: ObservableObject {
    struct State: Equatable {
        var loginButtonIsDisabled = false
        var activityIndicatorIsHidden = true
        var textFieldIsDisabled = false
        var alertIsDisplayed = false
        var alertMessage: String?
        var userID: String = ""
        var isLoggedIn = false
        
        static let initial = Self(
            loginButtonIsDisabled: false,
            activityIndicatorIsHidden: true,
            textFieldIsDisabled: false
        )
        
        static func fetching(userID: String) -> Self {
            Self(
                loginButtonIsDisabled: true,
                activityIndicatorIsHidden: false,
                textFieldIsDisabled: true,
                userID: userID
            )
        }

        static func loggedIn(userID: String) -> Self {
            Self(
                loginButtonIsDisabled: true,
                activityIndicatorIsHidden: true,
                textFieldIsDisabled: true,
                userID: userID,
                isLoggedIn: true
            )
        }
    
        static func failure(error: Error) -> Self {
            Self(
                loginButtonIsDisabled: false,
                activityIndicatorIsHidden: true,
                textFieldIsDisabled: false,
                alertIsDisplayed: true,
                alertMessage: error.localizedDescription
            )
        }
    }
    
    @Injected(Container.postsRepository) private var repository
    @Published var state: State = .initial
    
    init(state: State = .initial) {
        self.state = state
    }
    
    @MainActor
    func login() async {
        state = .fetching(userID: state.userID)
        
        do {
            try await repository.login(userID: state.userID)
            state = .loggedIn(userID: state.userID)
        } catch let repoError as RepositoryError {
            state = .failure(error: repoError)
        } catch {
            print("Unexpected error type after login(userID:) call")
//            state = .failure(error: RepositoryError.unknown(description: error.localizedDescription))
            state = .failure(error: RepositoryError.unknown(error: error))
        }
    }
}
