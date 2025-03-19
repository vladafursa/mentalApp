import Foundation
import Observation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
}
