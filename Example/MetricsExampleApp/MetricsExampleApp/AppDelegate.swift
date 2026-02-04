//
//  AppDelegate.swift
//  MetricsExampleApp
//
//  Created by FELIPE ROMANO RODRIGUEZ on 03/02/26.
//

import UIKit
import iOS_MetricsTVAzteca
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        MetricsAssembly.configure()
        
        return true
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


}

enum MetricsAssembly {

    static func configure() {

        let firebaseProvider = AnalyticsFirebaseEventReportManager()

        let permutiveProvider = AnalyticsPermutiveReportEventManager(
            configuration: PermutiveConfiguration(
                apiKey: "xxx",
                organisationId: "xxx",
                workspaceId: "xxx"
            )
        )

        AnalyticsDispatcher.shared.configure(
            providers: [
                firebaseProvider,
                permutiveProvider
            ]
        )
    }
}
