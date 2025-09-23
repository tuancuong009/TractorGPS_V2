//
//  UserDefaultPremium.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//

import Foundation
// MARK: - UserDefaults+Premium.swift
extension UserDefaults {
    private static let defaults = UserDefaults.standard
    
    static var isPremium: Bool {
        get {
            //true
            defaults.bool(forKey: Constants.UserDefaultsKeys.PRO_VERSION)
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaultsKeys.PRO_VERSION)
        }
    }
    
    static func checkPremiumAccess() -> Bool {
        return isPremium
    }
    
    static func upgradeToProVersion() {
        isPremium = true
    }
    
    static func revertToFreeVersion() {
        isPremium = false
    }
}
