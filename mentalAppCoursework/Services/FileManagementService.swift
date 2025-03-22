import FirebaseAuth
import FirebaseFirestore
import Foundation

class FileManagementService: ObservableObject {
    // creating singleton
    static let shared = FileManagementService()
    @Published var showAlert: Bool = false
    @Published var alertMessage: String?
    @Published var alertTitle: String?
    // creating of fileManager instance
    let fileManager = FileManager.default
    private init() {}

    // accessed and modified from
    // creation of folder by specified directory with missing intermediate folders and default settings
    func createFolder(directory: URL) {
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            print("Directory created at \(directory.path)")
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }

    // constracting a folder path
    func retrieveFolderURL() -> URL {
        // retrieve path to the app's directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uid = Auth.auth().currentUser?.uid ?? ""
        // each user will have own folder defined by user id
        let specificToUserPath = "MyMoodPhotos/" + uid
        let newDirectoryURL = documentsURL.appendingPathComponent(specificToUserPath)
        return newDirectoryURL
    }

    // check if folder already exists in a specified path
    func checkIfFolderAlreadyExists(usersPath: URL) -> Bool {
        if fileManager.fileExists(atPath: usersPath.path) {
            return true
        } else {
            return false
        }
    }

    // save photo taken into user's directory
    func savePhoto(_ image: UIImage) {
        let directoryForStoring = retrieveFolderURL()
        // create folder if doesn't exist
        if !checkIfFolderAlreadyExists(usersPath: directoryForStoring) {
            createFolder(directory: directoryForStoring)
        }
        // specifing compression quality: high with slight compression to reduce the file size
        if let photo = image.jpegData(compressionQuality: 0.9) {
            // setting 10am as unversal for further searches and comparisons(database queries)
            let today = Date()
            var calendar = Calendar.current
            let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
            // naming a file with today's date
            let filename = "\(selectedDate).jpg"
            let fileURL = directoryForStoring.appendingPathComponent(filename)

            do {
                // write the content of image into a file
                try photo.write(to: fileURL)
                print("saved successfully")
            } catch {
                print("unsuccessful photo saving")
            }
        } else {
            print("Couldn't save the photo")
        }
    }

    // retrieving all images from a directory
    func getAllSavedImages() -> [URL] {
        let directory = retrieveFolderURL()
        do {
            // no additipnal properties
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("error while fetching photos: \(error.localizedDescription)")
            // return empty array in case of errors
            return []
        }
    }

    // retrieve a photo for specified date by returning path of specified date's photo location: if nothing in here it will be handled in view
    func getPhotoForSelectedDate(_ date: Date) -> URL? {
        // setting 10am as unversal for further searches and comparisons(database queries)
        var calendar = Calendar.current
        let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) ?? date
        let directory = retrieveFolderURL()
        let fileName = "\(selectedDate).jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        return fileURL
    }

    // function that generates pdf with provided diary entries and saves into apps documents
    func createPDF(entries: [DiaryEntry]) -> URL? {
        // metadata setup
        let pdfMetaData = [
            kCGPDFContextCreator: "Mental health assistant",
            kCGPDFContextAuthor: "User",
        ]

        // create the PDF renderer
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        // configure page
        let pageWidth: CGFloat = 595.2 // A4 width
        let pageHeight: CGFloat = 841.8 // A4 height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        // initializing a PDF renderer for creation of PDF document with specified page dimensions and metadata
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // retrieve documents directory for the app
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find the Documents directory.")
            return nil
        }
        // define file's path
        let fileURL = documentsURL.appendingPathComponent("history.pdf")
        do {
            // write generated pdf file to file path
            try renderer.writePDF(to: fileURL) { context in
                // start new page
                context.beginPage()
                // text styling
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18),
                ]
                var yPosition: CGFloat = 20 // top margin
                // iterate over entries
                for entry in entries {
                    // Configure the formate of date
                    let timestamp = entry.date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    let formattedDate = dateFormatter.string(from: timestamp)

                    // get text for entry
                    let entryText = "Date: \(formattedDate)\nFeelings: \(entry.feelings)\nHappiness rate: \(entry.happinessScore)\n\n"
                    // apply attributes to text
                    let styledText = NSAttributedString(string: entryText, attributes: textAttributes)
                    // calculating rectangle's height
                    let textSize = styledText.size()
                    let currentTextRect = CGRect(x: 20, y: yPosition, width: 560, height: textSize.height)
                    // draw the text in specififed rectangle
                    styledText.draw(in: currentTextRect)
                    // calculate new y position
                    yPosition += textSize.height + 20
                    // check if new page is needed
                    if yPosition > 760 {
                        context.beginPage()
                        yPosition = 20
                    }

                    if let photoURL = FileManagementService.shared.getPhotoForSelectedDate(entry.date) {
                        if let photo = UIImage(contentsOfFile: photoURL.path) {
                            let originalPhotoSize = photo.size
                            // resize the photo
                            let resizedWidth: CGFloat = 255
                            let ratio = resizedWidth / originalPhotoSize.width
                            let resizedHeight = originalPhotoSize.height * ratio
                            // check if drawing image wil not go beyond the page as otherwise it will be cut on current page
                            let yPositionToCheck = yPosition + resizedHeight + 20
                            if yPositionToCheck > 760 {
                                context.beginPage()
                                yPosition = 20
                            }
                            // initialise a rectangle inside which a photo will be drawn
                            let photoRect = CGRect(x: 20, y: yPosition, width: resizedWidth, height: resizedHeight)
                            // draw a photo
                            photo.draw(in: photoRect)
                            // calculate new y
                            yPosition += resizedHeight + 20
                        }
                    }
                    // check if going to new page is needed
                    if yPosition > 760 {
                        context.beginPage()
                        yPosition = 20
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
