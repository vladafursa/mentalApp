import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class FirestoreService: ObservableObject {
    @Published var user: User?
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

    // adding diary entry to the database
    func addDiaryEntry(feelings: String, happinessScore: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid

        var calendar = Calendar.current
        var today = Date()
        today = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        try await db.collection("users").document(uid).collection("diary").document().setData(["date": today, "feelings": feelings, "happinessRate": happinessScore])
    }

    // checking if the user already submitted today's feelings
    func ifTheDayWasAlreadySubmitted() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        var calendar = Calendar.current
        var today = Date()
        today = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        let uid = user.uid
        let query =
            db.collection("users").document(uid).collection("diary")
                .whereField("date", isEqualTo: today)
        do {
            let snapshot = try await query.getDocuments()
            return !snapshot.documents.isEmpty
        } catch {
            throw error
        }
    }
}
