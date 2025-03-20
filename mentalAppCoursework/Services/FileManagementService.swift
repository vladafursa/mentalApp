import FirebaseAuth
import FirebaseFirestore
import Foundation

class FileManagementService: ObservableObject {
    static let shared = FileManagementService()
    @Published var showAlert: Bool = false
    @Published var alertMessage: String?
    @Published var alertTitle: String?
    let fileManager = FileManager.default
    private init() {}

    // accessed and modified from https://medium.com/@shashidj206/mastering-filemanager-in-swift-and-swiftui-7f29d6247644
    func createFolder(directory: URL) {
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            print("Directory created at \(directory.path)")
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }

    func retrieveFolderURL() -> URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uid = Auth.auth().currentUser?.uid ?? ""
        let specificToUserPath = "MyMoodPhotos/" + uid
        let newDirectoryURL = documentsURL.appendingPathComponent(specificToUserPath)
        return newDirectoryURL
    }

    func checkIfFolderAlreadyExists(usersPath: URL) -> Bool {
        if fileManager.fileExists(atPath: usersPath.path) {
            return true
        } else {
            return false
        }
    }

    func savePhoto(_ image: UIImage) {
        let directoryForStoring = retrieveFolderURL()
        if !checkIfFolderAlreadyExists(usersPath: directoryForStoring) {
            createFolder(directory: directoryForStoring)
        }
        if let photo = image.jpegData(compressionQuality: 0.9) {
            showAlert = false
            let today = Date()
            var calendar = Calendar.current
            let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
            let filename = "\(selectedDate).jpg"
            print(filename)
            let fileURL = directoryForStoring.appendingPathComponent(filename)

            do {
                try photo.write(to: fileURL)
                print("saved successfully")
            } catch {
                print("unsuccessful photo saving")
            }
        } else {
            showAlert = true
            alertTitle = "Couldn't save the photo"
            alertMessage = "..."
        }
    }

    // https://stackoverflow.com/questions/68641781/how-do-i-get-list-of-images-saved-in-a-folder
    func getAllSavedImages() -> [URL] {
        let directory = retrieveFolderURL()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            print(fileURLs)
            return fileURLs
        } catch {
            print("Ошибка при получении изображений: \(error.localizedDescription)")
            return []
        }
    }

    func getPhotoForSelectedDate(_ date: Date) -> URL? {
        var calendar = Calendar.current
        let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) ?? date
        let directory = retrieveFolderURL()
        let fileName = "\(selectedDate).jpg"
        print(fileName)
        let fileURL = directory.appendingPathComponent(fileName)
        return fileURL
    }
}
