import Firebase
import FirebaseAuth
import Foundation

// creating final singleton of authentication
final class AuthenticationService: ObservableObject {
    // variables that will be used across other services
    @Published var currentUser: FirebaseAuth.User?


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
        let result = try await auth.signIn(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = result.user
        }
    }

    // register function: adding to authentication and users database
    func register(name: String, email: String, password: String, age: Int) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await firestoreService.registerUser(uid: result.user.uid, email: email, name: name, age: age)
    }

    // signing user out
    func signOut() async throws {
        try await auth.signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
        }
    }

    // getting current user ID for future usage
    func getCurrentUserUID() -> String? {
        return currentUser?.uid
    }

    // changing password by sending the built-in verification link
    func forgotPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
}
