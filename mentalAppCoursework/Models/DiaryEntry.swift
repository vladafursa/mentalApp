import FirebaseFirestore
import Foundation

// struct representing user's diary entry for each day
struct DiaryEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var feelings: String
    var happinessScore: Int
}
