//
//  AppDelegate.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 24/9/25.
//


import ApphudSDK
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Apphud.start(apiKey: Constants.apiKey)
        return true
    }
}
