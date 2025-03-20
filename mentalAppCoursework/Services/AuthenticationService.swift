import Firebase
import FirebaseAuth
import Foundation

// creating final singleton of authentication
final class AuthenticationService: ObservableObject {
    // variables that will be used across views and other services
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String?
    @Published var alertMessage: String?
    @Published var dismissMessage: String?

    // creating instance of Auth
    private let auth = Auth.auth()
    // creating singleton
    static let shared = AuthenticationService()

    private let firestoreService = FirestoreService.shared

    private var authListener: AuthStateDidChangeListenerHandle?
    // adding listener to firebase that is triggered every time the authentication state changes
    private init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }

    // login function
    func login(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
            }
            // throwing error to be caught in ViewModel
        } catch {
            throw error
        }
    }

    /*
        func putIntoAuthenticationAndFirestore(name: String, email: String, password: String, age: Int) async throws {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                try await firestoreService.registerUser(uid: result.user.uid, email: email, name: name, age: age)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertTitle = "Successful registration"
                    self.alertMessage = "You can now loggin with your new credentials"
                    self.dismissMessage = "Okay"
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
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertTitle = "Unsuccessful registration"
                        self.alertMessage = error.localizedDescription
                        self.dismissMessage = "Try again"
                        self.showAlert = true
                    }
                }
            }
        }

        // form validations

        // accessed and modified from https://medium.com/@kalidoss.shanmugam/swift-ios-email-validation-best-practices-and-solutions-05456e265d2f
        func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            // return emailPredicate.evaluate(with: email)
            if emailPredicate.evaluate(with: email) {
                return true
            } else {
                showAlert = true
                alertTitle = "The form contains errors"
                alertMessage = "The email is in incorrect format"
                dismissMessage = "Try again"
                return false
            }
        }

        func containsUppercaseAndSpecialCharacter(_ string: String) -> Bool {
            let pattern = "^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
            let regex = try! NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.firstMatch(in: string, options: [], range: range) != nil
        }

        func checkIfFieldsAreEmpty(name: String, email: String, password: String, repeatedPassword: String, age: Int) -> Bool {
            if name.isEmpty || email.isEmpty || password.isEmpty || repeatedPassword.isEmpty || age.words.isEmpty {
                showAlert = true
                alertTitle = "The form contains errors"
                alertMessage = "You didn't input all fields"
                dismissMessage = "Try again"
                return true
            } else {
                return false
            }
        }

        func checkIfAgeIsValid(age: Int) -> Bool {
            if age < 18 {
                showAlert = true
                alertTitle = "You are not allowed to use the app"
                alertMessage = "The app is designed for adults only"
                dismissMessage = "Try again"
                return false
            } else {
                return true
            }
        }

        func checkAllowansOfPassword(password: String) -> Bool {
            if password.count < 8 || !containsUppercaseAndSpecialCharacter(password) {
                showAlert = true
                alertTitle = "The form contains errors"
                alertMessage = "The password should contain at least 1 capital letter, 1 special character and minimal size of 8 characters"
                dismissMessage = "Try again"
                return false
            } else {
                return true
            }
        }

        func checkIfPasswordsMatch(password: String, repeatedPassword: String) -> Bool {
            if password != repeatedPassword {
                showAlert = true
                alertTitle = "The form contains errors"
                alertMessage = "password should be equal repeated password"
                dismissMessage = "Try again"
                return false
            } else {
                return true
            }
        }

        func register(name: String, email: String, password: String, repeatedPassword: String, age: Int) async {
            isLoading = true
            Task {
                if isValidEmail(email) && !checkIfFieldsAreEmpty(name: name, email: email, password: password, repeatedPassword: repeatedPassword, age: age) && checkIfAgeIsValid(age: age) && checkAllowansOfPassword(password: password) && checkIfPasswordsMatch(password: password, repeatedPassword: repeatedPassword) {
                    try await putIntoAuthenticationAndFirestore(name: name, email: email, password: password, age: age)
                }
            }
            isLoading = false
        }

        func signOut() throws {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
        }

        func forgotPassword(email: String) async throws {
            do {
                try await auth.sendPasswordReset(withEmail: email)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertTitle = "Email sent successfully"
                    self.alertMessage = "Email was sent to your invox, check and press the link"
                }
            } catch {
                alertTitle = "Unsuccessful verification"
                showAlert = true
                alertMessage = error.localizedDescription
            }
        }

     */
    func getCurrentUserUID() -> String? {
        return currentUser?.uid
    }
}
