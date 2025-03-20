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
}
