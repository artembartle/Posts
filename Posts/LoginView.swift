// Developed by Artem Bartle

import SwiftUI
import Factory

struct LoginView: View {
    typealias ViewModel = LoginViewModel
    typealias VMState = LoginViewModel.State
    
    @ObservedObject var viewModel = Container.loginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: FeedView(),
                               isActive: $viewModel.state.isLoggedIn) {
                    EmptyView()
                }
                
                TextField("UserID", text: $viewModel.state.userID)
                    .background {
                        Color.blue
                    }
                    .padding()
                    .disabled(viewModel.state.textFieldIsDisabled)
                
                Button("Login") {
                    Task {
                        await viewModel.login()
                    }
                }
                .disabled(viewModel.state.loginButtonIsDisabled)
                .foregroundColor(.white)
                .padding()
                .background {
                    Color.blue
                }
            }
            .overlay {
                if !viewModel.state.activityIndicatorIsHidden {
                    ProgressView()
                }
            }
            .alert("Error",
                   isPresented: $viewModel.state.alertIsDisplayed,
                   presenting: viewModel.state.alertMessage,
                   actions: { _ in },
                   message: { Text($0) })
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = Container.apiClient.register {
            let dtos = (0..<10).map { i in
                PostDTO.stub(id: i)
            }
            let client = MockAPIClient()
            client.response = .success(dtos)
            client.response = .failure(.incorrectUserId)
            return client
        }
        
        let _ = Container.loginViewModel.register {
//            let state = LoginViewModel.State.fetching
            let error = RepositoryError.apiError(error: APIError.incorrectUserId)
            let state = LoginViewModel.State.failure(error: error)
            let vm = LoginViewModel(state: state)
            return vm
        }
        
        LoginView()
    }
}
