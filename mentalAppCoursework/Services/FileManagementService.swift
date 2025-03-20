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

    func createPDF(entries: [DiaryEntry]) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyApp",
            kCGPDFContextAuthor: "User",
        ]

        // Create the PDF renderer
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 595.2 // A4 width
        let pageHeight: CGFloat = 841.8 // A4 height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find the Documents directory.")
            return nil
        }
        let fileURL = documentsURL.appendingPathComponent("generated.pdf")
        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()

                let textRect = CGRect(x: 20, y: 20, width: 560, height: 760)

                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18),
                ]
                var yPosition: CGFloat = 20
                for entry in entries {
                    let entryText = "Date: \(entry.date)\nMood: \(entry.feelings)\nContent: \(entry.happinessScore)\n\n"
                    let attributedText = NSAttributedString(string: entryText, attributes: textAttributes)
                    let textSize = attributedText.size()
                    let currentTextRect = CGRect(x: 20, y: yPosition, width: 560, height: textSize.height)
                    attributedText.draw(in: currentTextRect)
                    yPosition += textSize.height + 40
                    if let photoURL = FileManagementService.shared.getPhotoForSelectedDate(entry.date) {
                        if let photo = UIImage(contentsOfFile: photoURL.path) {
                            let originalSize = photo.size
                            let scaledWidth: CGFloat = 560
                            let scaleFactor = scaledWidth / originalSize.width
                            let scaledHeight = originalSize.height * scaleFactor
                            let photoRect = CGRect(x: 20, y: yPosition, width: scaledWidth, height: scaledHeight)

                            photo.draw(in: photoRect)

                            yPosition += scaledHeight + 30
                        }
                    }

                    if yPosition > 760 {
                        context.beginPage()
                        yPosition = 20 // Сбросить позицию для новой страницы
                    }
                }
            }
            print("PDF saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Error creating PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
