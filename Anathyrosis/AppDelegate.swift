import UIKit
import Alamofire
import AppsFlyerLib
import AppTrackingTransparency

final class AppDelegate: NSObject, UIApplicationDelegate {
    private static let bind = "com.anathyrosis.shaft"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = Self.bind
        APIConfig.apply()
        AppsFlyerLib.shared().appsFlyerDevKey = "jxNwhe9VSnwgLFyWPoGuaR"
        AppsFlyerLib.shared().appleAppID = "6817546258"
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(
            self, selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        return true
    }

    @objc private func applicationDidBecomeActive() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { @Sendable _ in
                AppsFlyerLib.shared().start()
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
}
