//
//  NotificationManager.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 24/9/25.
//

import UserNotifications
import StoreKit

class TrialNotificationManager {
    static let shared = TrialNotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func scheduleTrialExpirationNotification(startDate: Date) {
        // Calculate notification date (5 days from start)
        let notificationDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let content = UNMutableNotificationContent()
        content.title = "Trial Period Ending Soon"
        content.body = "Your free trial will end in 1 day. Would you like to continue with premium access?"
        content.sound = .default
        
        // Create trigger for specific date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "trial-expiration",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelTrialNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["trial-expiration"])
    }
}
