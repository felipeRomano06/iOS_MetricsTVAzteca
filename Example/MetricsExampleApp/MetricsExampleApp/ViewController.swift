//
//  ViewController.swift
//  MetricsExampleApp
//
//  Created by FELIPE ROMANO RODRIGUEZ on 03/02/26.
//

import UIKit
import FirebaseAnalytics

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
            Analytics.logEvent("connection_test", parameters: [
                "source": "manual_test"
            ])
        }
    }
    
}

