import UIKit
import Flutter
import Firebase
import UserNotifications
import GoogleMaps
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyBYqO1N5Rr6fnLeOz4fxSPcPwHy77CNe_c")
        if FirebaseApp.app() == nil {
            FirebaseApp.configure() // Call only if not already configured
        }
        if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
            // We have a link, propagate it to your Flutter app or not
            AppLinks.shared.handleLink(url: url)
            return true // Returning true will stop the propagation to other packages
        }
        
        UNUserNotificationCenter.current().delegate = self
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
