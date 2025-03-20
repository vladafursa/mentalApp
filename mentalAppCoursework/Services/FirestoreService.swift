import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class FirestoreService: ObservableObject {
    @Published var user: User?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String?
    @Published var alertTitle: String?
    @Published var hasSubmitted = false
    private var db = Firestore.firestore()
    static let shared = FirestoreService()
    private init() {}

    // fetching username from database, if not successful return just user
    func findName() async -> String {
        guard let user = Auth.auth().currentUser else {
            return "User"
        }
        let uid = user.uid
        let docRef = db.collection("users").document(uid)

        do {
            let document = try await docRef.getDocument()
            let username = (document.get("name") as? String) ?? "User"
            return username
        } catch {
            return "User"
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
