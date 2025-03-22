import Firebase
import Foundation
import Observation

class HistoryViewModel: ObservableObject {
    @Published var specificDiaryEntry: DiaryEntry? = nil
    @Published var diary: [DiaryEntry] = []
    @Published var filteredDiaryEntries: [DiaryEntry] = []
    @Published var alertTitle: String?
    @Published var showAlert = false
    @Published var alertMessage = ""

    // call firestore service and retrieve specificDiaryEntry variable, catch arrors by showing alerts
    func fetchSpecififcDate(date: Date) {
        Task {
            do {
                if let diaryEntry = try await FirestoreService.shared.fetchSpecificDiaryEntry(date: date) {
                    DispatchQueue.main.async {
                        self.specificDiaryEntry = diaryEntry
                    } // if not found, assign nil value
                } else {
                    DispatchQueue.main.async {
                        self.specificDiaryEntry = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertTitle = "Error"
                    self.alertMessage = "couldn't fetch the data"
                    self.showAlert = true
                }
            }
        }
    }

    // call firestore service and retrieve and array of diary entries, catch errors by showing alert
    func fetchAllDiaryEntries() {
        Task {
            do {
                let diaries = try await FirestoreService.shared.fetchAllDiaryEntries()
                DispatchQueue.main.async {
                    self.diary = diaries
                    self.filteredDiaryEntries = diaries
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertTitle = "Error"
                    self.alertMessage = "couldn't fetch the data"
                    self.showAlert = true
                }
            }
        }
    }

    // filters options based on value provided: values inside 1 weeek/ 1 month etc
    func filter(period: Int) {
        let calendar = Calendar.current
        let today = Date()
        DispatchQueue.main.async {
            self.filteredDiaryEntries = self.diary.filter { diaryEntry in
                diaryEntry.date >= calendar.date(byAdding: .day, value: -period, to: today)! // substracts the number of days specified by period
                // filters only days that are greater or equal to specified number of days before the current date
            }
        }
    }

    // assigns filtered entries back to usual ones
    func resetfilter() {
        let calendar = Calendar.current
        let today = Date()
        DispatchQueue.main.async {
            self.filteredDiaryEntries = self.diary
        }
    }

    // calls filemenagement function to create pfd, catches errors by showing alerts, also shows success alert
    func CreatePDF() {
        if let url =
            FileManagementService.shared.createPDF(entries: diary)
        {
            DispatchQueue.main.async {
                self.alertTitle = "Success"
                self.alertMessage = "you can find your pdf in downloads"
                self.showAlert = true
            }
        } else {
            DispatchQueue.main.async {
                self.alertTitle = "Error"
                self.alertMessage = "couldn't download pdf"
                self.showAlert = true
            }
        }
    }
}
