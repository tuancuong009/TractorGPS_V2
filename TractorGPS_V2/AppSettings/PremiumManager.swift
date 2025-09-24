import Foundation
import ApphudSDK
import StoreKit

@MainActor
class PremiumManager: ObservableObject {
    
    static let shared = PremiumManager()
    
    @Published var isPremium: Bool = false
    @Published var isLoading = false
    @Published var showPremiumToast = false
    @Published var messageToast = ""
    
    private init() {
        Task { await checkPremiumStatus() }
    }
    
    /// Kiểm tra trạng thái Premium
    func checkPremiumStatus() async {
        let hasSub = Apphud.hasActiveSubscription()
        self.isPremium = hasSub
        print("Premium status: \(hasSub ? "✅ Active" : "❌ Inactive")")
    }
    
    /// Mua gói
    func purchaseProduct(product: ApphudProduct) {
        isLoading = true
        Apphud.purchase(product) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            if result.success {
                if let subscription = result.subscription, subscription.isActive() {
                    print("✅ Purchase successful for: \(product.productId)")
                    
                    Task {
                        await self.checkPremiumStatus()
                        
                        if self.isPremium {
                            let notificationGranted = await TrialNotificationManager.shared.requestNotificationPermission()
                            if notificationGranted {
                                TrialNotificationManager.shared.scheduleTrialExpirationNotification(startDate: Date())
                            }
                        }
                    }
                    
                } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                    print("✅ Non-renewing purchase successful for: \(product.productId)")
                    
                    Task {
                        await self.checkPremiumStatus()
                        
                        if self.isPremium {
                            let notificationGranted = await TrialNotificationManager.shared.requestNotificationPermission()
                            if notificationGranted {
                                TrialNotificationManager.shared.scheduleTrialExpirationNotification(startDate: Date())
                            }
                        }
                    }
                    
                } else {
                    self.showPremiumToast = true
                    self.messageToast = result.error?.localizedDescription ?? "Purchase failed"
                }
                
            } else if let error = result.error {
                if (error as NSError).code == SKError.paymentCancelled.rawValue {
                    print("⚠️ User canceled the purchase.")
                    self.showPremiumToast = true
                    self.messageToast = "User canceled the purchase"
                } else {
                    print("❌ Purchase failed: \(error.localizedDescription)")
                    self.showPremiumToast = true
                    self.messageToast = error.localizedDescription
                }
                
            } else {
                print("⚠️ Purchase canceled.")
                self.showPremiumToast = true
                self.messageToast = "Purchase canceled"
            }
        }
    }

    
    /// Khôi phục gói
    func restorePurchases() {
        isLoading = true
        Apphud.restorePurchases { [weak self] subscriptions, purchases, error in
            guard let self else { return }
            self.isLoading = false
            
            if Apphud.hasActiveSubscription() {
                Task { await self.checkPremiumStatus() }
            } else {
                if let error = error {
                    if (error as NSError).code == SKError.paymentCancelled.rawValue {
                        print("⚠️ User canceled restore purchases.")
                        self.showPremiumToast = true
                        self.messageToast = "User canceled the restore purchases operation"
                    } else {
                        print("❌ Restore failed: \(error.localizedDescription)")
                        self.showPremiumToast = true
                        self.messageToast = error.localizedDescription
                    }
                } else {
                    self.showPremiumToast = true
                    self.messageToast = "No active subscriptions found"
                }
            }
        }
    }
}
