import FirebaseFirestore
import Foundation

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var age: Int
    var email: String
}
