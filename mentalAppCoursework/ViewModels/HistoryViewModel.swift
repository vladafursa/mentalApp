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

    func fetchSpecififcDate(date: Date) {
        Task {
            do {
                if let diaryEntry = try await FirestoreService.shared.fetchSpecificDiaryEntry(date: date) {
                    DispatchQueue.main.async {
                        self.specificDiaryEntry = diaryEntry
                    }
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

    func filter(period: Int) {
        let calendar = Calendar.current
        let today = Date()
        DispatchQueue.main.async {
            self.filteredDiaryEntries = self.diary.filter { diaryEntry in
                diaryEntry.date >= calendar.date(byAdding: .day, value: -period, to: today)!
            }
        }
    }

    func resetfilter() {
        let calendar = Calendar.current
        let today = Date()
        DispatchQueue.main.async {
            self.filteredDiaryEntries = self.diary
        }
    }

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
