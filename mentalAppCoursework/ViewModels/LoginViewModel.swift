import Firebase
import FirebaseAuth
import Foundation
import Observation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var alertTitle: String?

    // calling service to caught errors, change states and show alerts
    func login() {
        isLoading = true
        Task {
            do {
                try await AuthenticationService.shared.login(email: email, password: password)
                DispatchQueue.main.async {
                    self.alertMessage = nil
                    self.showAlert = false
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            } catch {
                if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                    DispatchQueue.main.async {
                        switch errorCode.code {
                        case .wrongPassword, .invalidCredential, .userNotFound:
                            self.alertTitle = "Cannot verify user"
                            self.alertMessage = "You provided incorrect email or password"
                        default:
                            self.alertTitle = "Unsuccessful login"
                            self.alertMessage = error.localizedDescription
                        }
                        self.showAlert = true
                        self.isLoggedIn = false
                        self.isLoading = false
                    }
                }
            }
        }
        clearFields()
    }

    // clearing input fields
    func clearFields() {
        DispatchQueue.main.async {
            self.email = ""

            self.password = ""
        }
    }

    // opening dialing number with emergency helpline
    func openEmergencyCall() {
        let phoneNumber = "08081963779"
        let numberUrl = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(numberUrl) {
            UIApplication.shared.open(numberUrl)
        }
    }
}
