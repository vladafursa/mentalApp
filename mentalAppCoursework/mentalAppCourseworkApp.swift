import Firebase
import FirebaseCore
import SwiftUI

@main
struct mentalAppCoursework: App {
    // registration of app delegate for notifications, firebase and maps
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
