import Firebase
import Foundation
import Observation

class HomeViewModel: ObservableObject {
    @Published var rating: Int = 0
    @Published var feelings: String = ""
    @Published var hasActionBeenPerformed = false
    @Published var alertTitle: String?
    @Published var showAlert = false
    @Published var showSupportAlert = false
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
//calling firestore service to find out if the entry was already submitted
    func checkIfSubmitted() {
        Task {
            do {
                let submitted = try await FirestoreService.shared.ifTheDayWasAlreadySubmitted()
                DispatchQueue.main.async {
                    self.hasSubmitted = submitted
                }
            } catch {
                self.hasSubmitted = false
            }
        }
    }
//calling firestore service to save data into firebase and catch errors by presenting alert
    func addEntry() {
        if !checkInput() {
            Task {
                do {
                    try await FirestoreService.shared.addDiaryEntry(feelings: feelings, happinessScore: rating)
                    stayHappyReminder()
                    DispatchQueue.main.async {
                        self.hasSubmitted = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.hasSubmitted = false
                        self.showAlert = true
                        self.alertTitle = "Couldn't save the data"
                        self.alertMessage = "An error occured while saving your entry"
                    }
                }
            }
        }
    }
//show motivating alert if user rated happiness low
    func stayHappyReminder() {
        if rating < 3 {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "Do not be sad!"
                self.alertMessage = "Some days can be tough,  but remember, brighter moments are just around the corner. Stay happy!"
            }
        }
    }
    
    func checkIfImageWasTaken(image:  UIImage)-> Bool{
     if image == nil {
         DispatchQueue.main.async {
             self.showAlert = true
             self.alertTitle = "Missing Information"
             self.alertMessage = "Please take photo"
         }
         return false
     } else {
         return true
        }
    }
    
    func saveImage(image:  UIImage){
        FileManagementService.shared.savePhoto(image)
    }
     
//form validation: not allow inputing just empty spaces and 0 rate
    func checkInput() -> Bool {
        if feelings.filter({ !$0.isWhitespace }).isEmpty || rating == 0 {
            DispatchQueue.main.async {
                self.showAlert = true
                self.alertTitle = "Missing Information"
                self.alertMessage = "Please fill out all fields"
            }
            return true
        } else {
            return false
        }
    }
    
    
    func showPhotoAlert() {
        DispatchQueue.main.async {
            self.showAlert = true
            self.alertTitle = "Missing Information"
            self.alertMessage = "Please take a selfie"
        }
    }

}
