/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The application delegate.
*/

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        //registerForPushNotifications()
//        return true
//    }
    
    var window: UIWindow?

    // Configure a FirebaseApp shared instance
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(FirebaseLoggerLevel.min)
        FirebaseConfiguration.shared.analyticsConfiguration.setAnalyticsCollectionEnabled(false)
        FirebaseApp.configure()

        return true
    }
    
    func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunched") {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         // 1. Convert device token to string
         let tokenParts = deviceToken.map { data -> String in
             return String(format: "%02.2hhx", data)
         }
         let token = tokenParts.joined()
         // 2. Print device token to use for PNs payloads
         print("Device Token: \(token)")
     }

     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         // 1. Print out error if PNs registration not successful
         print("Failed to register for remote notifications with error: \(error)")
     }
    
    func registerForPushNotifications() {
          UNUserNotificationCenter.current().delegate = self
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
              (granted, error) in
              print("Permission granted: \(granted)")
              // 1. Check if permission granted
              guard granted else { return }
              // 2. Attempt registration for remote notifications on the main thread
              DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
              }
          }
      }
    
    

}

