import Firebase
import Foundation
import Observation

class HomeViewModel: ObservableObject {
    @Published var rating: Int = 0
    @Published var feelings: String = ""
    @Published var hasActionBeenPerformed = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var hasSubmitted: Bool = false
    @Published var username: String = "User"

    // calling service to get username, if not succesfull use just User
    func findUserName() {
        Task {
            do {
                let username = await FirestoreService.shared.findName()
                DispatchQueue.main.async {
                    self.username = username
                }
            } catch {
                self.username = "User"
            }
        }
    }
}
