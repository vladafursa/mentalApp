import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class FirestoreService: ObservableObject {
    @Published var user: User?
    @Published var username: String = "User"
    @Published var showAlert: Bool = false
    @Published var alertMessage: String?
    @Published var alertTitle: String?
    @Published var hasSubmitted = false
    private var db = Firestore.firestore()
    static let shared = FirestoreService()
    private init() {}

    func findName() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                self.username = (document.get("name") as? String) ?? "User"
            } else {
                print("Document does not exist or an error occurred: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func registerUser(uid: String, email: String, name: String, age: Int) async throws {
        do {
            try await db.collection("users").document(uid).setData(["name": name, "email": email, "age": age])
        } catch {
            throw error
        }
    }
}
