import Flutter
import UIKit
import GooleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if let googleMapsAPIKey = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String {
          GMSServices.provideAPIKey(googleMapsAPIKey)
      } else {
          print("❌ ERREUR : Clé API Google Maps non trouvée !")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
