import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    // actions performed when the application is launched
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        // configeration of firebase
        FirebaseApp.configure()

        // optios of notifications
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        // request for sending notifications
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            // for debugging
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
            print("Notification permissions granted: \(granted)")
        }
        // set notifications delegate
        UNUserNotificationCenter.current().delegate = self
        // registration for remote notifications
        application.registerForRemoteNotifications()

        // Set Messaging Delegate
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    // sending the token to the server
    func application(_: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        Messaging.messaging().apnsToken = deviceToken
    }

    // called when the user is using the app: IOS doesn't show the notification when the app is in use, so this overrides its behaviour
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.banner, .list, .sound])
    }

    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase Messaging FCM Token: \(fcmToken ?? "")")
    }
}
