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

    // calling service to caught errors, change states in the main thread and show alerts
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

    // calling service to caught errors, change states and show alerts
    func forgotPassword() {
        isLoading = true
        Task {
            do {
                try await AuthenticationService.shared.forgotPassword(email: email)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertTitle = "Email sent successfully"
                    self.alertMessage = "Email was sent to your inbox, check and press the link"
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertTitle = "Unsuccessful verification"
                    self.alertMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
        clearFields()
    }

    // emptying input fields
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

    func logout() {
        Task {
            do {
                try await AuthenticationService.shared.signOut()
            } catch {}
        }
    }
}
