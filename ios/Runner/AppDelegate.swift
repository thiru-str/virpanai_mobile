import UIKit
import Flutter
import Firebase
import UserNotifications
import GoogleMapsUtils

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure() // Call only if not already configured
        }
        GMSServices.provideAPIKey("AIzaSyBYqO1N5Rr6fnLeOz4fxSPcPwHy77CNe_c")
        UNUserNotificationCenter.current().delegate = self
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
