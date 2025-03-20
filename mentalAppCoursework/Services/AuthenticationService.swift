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

    // register function: adding to authentication and users database
    func register(name: String, email: String, password: String, age: Int) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            try await firestoreService.registerUser(uid: result.user.uid, email: email, name: name, age: age)
        } catch {
            throw error
        }
    }

    // signing user out
    func signOut() throws {
        try auth.signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
        }
    }

    func getCurrentUserUID() -> String? {
        return currentUser?.uid
    }
    /*

        func forgotPassword(email: String) async throws {
            do {
                try await auth.sendPasswordReset(withEmail: email)
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertTitle = "Email sent successfully"
                    self.alertMessage = "Email was sent to your inbox, check and press the link"
                }
            } catch {
                alertTitle = "Unsuccessful verification"
                showAlert = true
                alertMessage = error.localizedDescription
            }
        }

     */
}
