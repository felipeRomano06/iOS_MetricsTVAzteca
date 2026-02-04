//
//  ViewController.swift
//  MetricsExampleApp
//
//  Created by FELIPE ROMANO RODRIGUEZ on 03/02/26.
//

import UIKit
import FirebaseAnalytics
import iOS_MetricsTVAzteca

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Analytics.logEvent("firebase_connection_test", parameters: [
                "source": "manual_test"
            ])
        }
    }

    @IBAction func sendTest(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let param = MetricsParam(
                firebaseScreen: "screen-example",
                section: "example-section",
                channel: "example-channel",
                programm: "example-programm",
                countryCode: "MX",
                loginStatus:.anonymous,
                idfa: "example-idfa",
                im: "example-im",
                isRestricted: .isFalse
            )
            
            
            AnalyticsDispatcher.shared.track(event: .screenView, params: param)
        }
    }
    
}



    
