import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
//import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
//    UNUserNotificationCenter.current().requestAuthorization(
//          options: [.alert, .badge, .sound]
//        ) { granted, error in
//          if granted {
//            print("Notification permissions granted.")
//          } else {
//            print("Notification permissions denied.")
//          }
//        }
//
//    UNUserNotificationCenter.current().delegate = self
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let upiChannel = FlutterMethodChannel(name: "com.creatoo/upi_payment",
                                          binaryMessenger: controller.binaryMessenger)
    upiChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "launchUpi" {
          guard let args = call.arguments as? [String: Any],
                let uriStr = args["uri"] as? String,
                let url = URL(string: uriStr) else {
              result(FlutterError(code: "INVALID_ARGS", message: "Invalid URI", details: nil))
              return
          }
          if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
              // iOS P2P doesn't provide intent callback, default to Pending
              let map: [String: String] = ["Status": "APP_CLOSED_OR_NO_RESPONSE"]
              result(map)
          } else {
              result(FlutterError(code: "NO_APPS", message: "Cannot open URI", details: nil))
          }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
//    override func application(_ application: UIApplication,
//      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//       Messaging.messaging().apnsToken = deviceToken
//       print("Token: \(deviceToken)")
//       super.application(application,
//       didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//     }

}
