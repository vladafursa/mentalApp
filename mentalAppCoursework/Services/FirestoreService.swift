import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class FirestoreService: ObservableObject {
    // defining variables
    @Published var user: User?
    private var db = Firestore.firestore()
    // creating singleton
    static let shared = FirestoreService()
    private init() {}

    // fetching username from database, if not successful return just user
    func findName() async -> String {
        // safely retrieving currently logged in user's id
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

    // adding user to collection users in firebase
    func registerUser(uid: String, email: String, name: String, age: Int) async throws {
        do {
            try await db.collection("users").document(uid).setData(["name": name, "email": email, "age": age])
        } catch {
            throw error
        }
    }

    // adding diary entry to the database
    func addDiaryEntry(feelings: String, happinessScore: Int) async throws {
        // safely retrieving currently logged in user's id
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid

        // setting 10am as unversal for further searches and comparisons(database queries)
        var calendar = Calendar.current
        var today = Date()
        today = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
        try await db.collection("users").document(uid).collection("diary").document().setData(["date": today, "feelings": feelings, "happinessRate": happinessScore])
    }

    // checking if the user already submitted today's feelings
    func ifTheDayWasAlreadySubmitted() async throws -> Bool {
        // safely retrieving currently logged in user's id
        guard let user = Auth.auth().currentUser else {
            return false
        }
        // setting 10am as unversal for further searches and comparisons(database queries)
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
            // throw error that will be handled in a viewmodel
            throw error
        }
    }

    // retriving diary entry for a specified date
    func fetchSpecificDiaryEntry(date: Date) async throws -> DiaryEntry? {
        // safely retrieving currently logged in user's id
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        let uid = user.uid
        // setting 10am as unversal for further searches and comparisons(database queries)
        var calendar = Calendar.current
        let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) ?? date
        let query =
            db.collection("users").document(uid).collection("diary")
                .whereField("date", isEqualTo: selectedDate)

        let snapshot = try await query.getDocuments(source: .server) // to have the latest version

        if let document = snapshot.documents.first {
            let data = document.data()
            // check if all fields are present, otherwise return nill(skip entry)
            if let feelings = data["feelings"] as? String,
               let dateTimestamp = data["date"] as? Timestamp,
               let happinessScore = data["happinessRate"] as? Int
            {
                let date = dateTimestamp.dateValue()
                let diaryEntry = DiaryEntry(date: date, feelings: feelings, happinessScore: happinessScore)
                return diaryEntry
            } else {
                return nil
            } // return nill of no document found
        } else {
            return nil
        }
    }

    func fetchAllDiaryEntries() async throws -> [DiaryEntry] {
        // safely retrieving currently logged in user's id
        guard let user = Auth.auth().currentUser else {
            return []
        }
        let uid = user.uid
        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("diary")
            .getDocuments()
        // iteration through each document and transformation
        var diaryEntries: [DiaryEntry] = snapshot.documents.compactMap { document in
            let data = document.data()
            // check if it contains all fields and they are valid
            if let feelings = data["feelings"] as? String,
               let dateTimestamp = data["date"] as? Timestamp,
               let happinessScore = data["happinessRate"] as? Int
            {
                let date = dateTimestamp.dateValue()
                return DiaryEntry(date: date, feelings: feelings, happinessScore: happinessScore)
            } else {
                // skip this document
                return nil
            }
        }
        // sorting by date
        diaryEntries.sort { $0.date < $1.date }
        return diaryEntries
    }
}
