import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAOV2urxC1Kcsj2VEiz7uE1OrvT4fZEoW0")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
