import Firebase
import FirebaseAuth
import Foundation
import Observation

class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var password: String = ""
    @Published var repeatedPassword: String = ""
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var alertTitle: String?
    @Published var dismissMessage: String?

    // calling service to caught errors, change states and show alerts
    func register() {
        if validateForm() {
            isLoading = true
            Task {
                do {
                    try await AuthenticationService.shared.register(name: username, email: email, password: password, age: age)
                    DispatchQueue.main.async {
                        self.showAlert = true
                        self.alertTitle = "Successful registration"
                        self.alertMessage = "You can now loggin with your new credentials"
                        self.dismissMessage = "Okay"
                        self.isLoading = false
                    }

                } catch {
                    if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                        DispatchQueue.main.async {
                            switch errorCode {
                            case .emailAlreadyInUse:
                                self.alertMessage = "User with such email already exists"
                            default:
                                self.alertMessage = error.localizedDescription
                            }
                            self.alertTitle = "Unsuccessful registration"
                            self.dismissMessage = "Try again"
                            self.showAlert = true
                            self.isLoading = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alertTitle = "Unsuccessful registration"
                            self.alertMessage = error.localizedDescription
                            self.dismissMessage = "Try again"
                            self.showAlert = true
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        clearFields()
    }

    // form validations

    // accessed and modified from https://medium.com/@kalidoss.shanmugam/swift-ios-email-validation-best-practices-and-solutions-05456e265d2f
    func checkIfFieldsAreEmpty() -> Bool {
        if username.isEmpty || email.isEmpty || password.isEmpty || repeatedPassword.isEmpty || age.words.isEmpty {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "The form contains errors"
                self.alertMessage = "You didn't input all fields"
                self.dismissMessage = "Try again"
            }
            return true
        } else {
            return false
        }
    }

    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        if emailPredicate.evaluate(with: email) {
            return true
        } else {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "The form contains errors"
                self.alertMessage = "The email is in incorrect format"
                self.dismissMessage = "Try again"
            }
            return false
        }
    }

    func containsUppercaseAndSpecialCharacter(_ string: String) -> Bool {
        let pattern = "^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }

    func checkIfAgeIsValid() -> Bool {
        if age < 18 || age > 100 {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "You are not allowed to use the app"
                self.alertMessage = "The app is designed for adults only and your age should be valid"
                self.dismissMessage = "Try again"
            }
            return false
        } else {
            return true
        }
    }

    func checkAllowansOfPassword() -> Bool {
        if password.count < 8 || !containsUppercaseAndSpecialCharacter(password) {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "The form contains errors"
                self.alertMessage = "The password should contain at least 1 capital letter, 1 special character and minimal size of 8 characters"
                self.dismissMessage = "Try again"
            }
            return false
        } else {
            return true
        }
    }

    func checkIfPasswordsMatch() -> Bool {
        if password != repeatedPassword {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "The form contains errors"
                self.alertMessage = "password should be equal repeated password"
                self.dismissMessage = "Try again"
            }
            return false
        } else {
            return true
        }
    }

    // performing all form checks
    func validateForm() -> Bool {
        if isValidEmail() && !checkIfFieldsAreEmpty() && checkIfAgeIsValid() && checkAllowansOfPassword() && checkIfPasswordsMatch() {
            return true
        } else {
            return false
        }
    }

    // emptying input fields
    func clearFields() {
        DispatchQueue.main.async {
            self.username = ""
            self.email = ""
            self.age = 0
            self.password = ""
            self.repeatedPassword = ""
        }
    }
}
