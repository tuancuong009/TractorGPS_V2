//
//  TrialIntroView3.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 16/9/25.
//
import SwiftUI
import ApphudSDK
import StoreKit
struct TrialIntroView3: View {
    @ObservedObject var appState: AppState
    @State private var selectProduct: ApphudProduct?
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var isRestore = false
    @StateObject private var safariManager = SafariManager.shared
    @StateObject private var manager = ShareAndMailManager()
    var body: some View {
        ZStack{
            ScrollView(showsIndicators: false){
                VStack(spacing: 20) {
                    
                    HStack {
                        Button("Restore") {
                            isRestore = true
                            premiumManager.restorePurchases()
                        }
                            .foregroundColor(Color.init(hex: "7B7B7B")).font(AppFonts.medium(size: 12))
                            .padding(.vertical,8).padding(.horizontal,12).background(AppTheme.surfaceTertiary).clipShape(Capsule())
                        Spacer()
                        Menu {
                            Button {
                                print("Need Help tapped")
                                var versionStr = ""
                                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                    versionStr = "\(version)"
                                }
                                
                                let message =
                                    """
                                    <b>Write your message below:</b><br><br><br><br><br><br><br><br><br><br>
                                    
                                    
                                    
                                    <span style="font-size:12px; color: gray;">
                                        <b>Diagnostic Information</b>
                                        <br>App Version: \(versionStr)
                                        <br>Platform: iOS
                                        <br>Device: \(UIDevice.current.modelName)
                                        <br>OS Version: \(UIDevice.current.systemVersion)
                                        <br>Language: English"
                                    </span>
                                    """
                                
                                let mail = MailData(
                                    to: [AppSettings.EMAIL],
                                    subject: "Contact Us - \(AppSettings.APP_NAME) for iOS",
                                    body: message,
                                    isHTML: true,
                                    attachments: []
                                )
                                manager.sendMail(mail)
                                
                            } label: {
                                Label("Need Help?", image: "message")
                            }
                            
                            Divider() // ngăn cách
                            
                            Button("Privacy Policy") {
                                safariManager.open(AppSettings.PRIVACY)
                                print("Privacy Policy tapped")
                            }
                            
                            Button("Terms of Service") {
                                safariManager.open(AppSettings.TERMS)
                                print("Terms of Service tapped")
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis").frame(width: 36, height: 36)
                                .foregroundColor(Color.init(hex: "7B7B7B")).background(AppTheme.surfaceTertiary).clipShape(Capsule())
                        }
                        
                       
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Image("icPaywall")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 10)
                    
                    Text("3 Days for Free")
                        .font(AppFonts.bold(size: 28))
                        .foregroundColor(AppTheme.paywall)
                    if let selectProduct = selectProduct, let skProduct = selectProduct.skProduct {
                        Text("Then \(self.formatPrice(skProduct: skProduct)) / Year\n(billed annually after trial)")
                            .font(AppFonts.medium(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.textPrimary)
                            .minimumScaleFactor(0.5)
                    }
                    else{
                        ProgressView()
                    }
                   
                    Image("rate_paywall")
                    
                    HStack(spacing: 30) {
                        VStack {
                            Image("icFuel")
                            Text("Fuel\nSaved").font(AppFonts.medium(size: 14))
                                .multilineTextAlignment(.center).minimumScaleFactor(0.5)
                        }
                        
                        Divider().foregroundColor(Color.init(hex: "D9D9D9")).frame(height: 44)
                        VStack {
                            Image("icInput")
                            Text("Inputs\nOptimized").minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .font(AppFonts.medium(size: 14))
                        }
                        Divider().foregroundColor(Color.init(hex: "D9D9D9")).frame(height: 44)
                        VStack {
                            Image("icPrice")
                            Text("Bigger\nMargins").minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                                .font(AppFonts.medium(size: 14))
                        }
                    }
                    .padding(.top, 8)
                    
                  
                    
                    Spacer()
                    
                    HStack{
                        Image("icProtect")
                        Text("No Payment Now. Secured by Apple").minimumScaleFactor(0.5)
                            .font(AppFonts.medium(size: 15))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    Button(action: {
                        guard let selectProduct = selectProduct else{
                            premiumManager.showPremiumToast = true
                            premiumManager.messageToast = "No products available for purchase"
                            return
                        }
                        isRestore = false
                        premiumManager.purchaseProduct(product: selectProduct)
                    }) {
                        HStack {
                            Spacer()
                            Text("Try for Free 🙌🏼")
                                .foregroundColor(.white).multilineTextAlignment(.center)
                                .font(AppFonts.semiBold(size: 20))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.init(hex: "269832"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)
                }
                
            }
            .onAppear(perform: {
                loadProducts()
            })
            .toast(isShowing: $premiumManager.showPremiumToast,
                   message: premiumManager.messageToast,
                           systemImage: "xmark.circle.fill",
                           backgroundColor: .red)
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $manager.presentMailSheet, onDismiss: {
                manager.mailData = nil
            }) {
                if let mail = manager.mailData {
                    MailView(mail: mail) { result in
                        
                        manager.presentMailSheet = false
                    }
                } else {
                    // fallback empty view
                    EmptyView()
                }
            }
            .sheet(item: $safariManager.safariURL) { safariURL in
                SafariView(url: safariURL.url)
            }
            LoadingOverlay(message: isRestore ? "Restoring Purchase..." : "Processing Purchase...", isShowing: $premiumManager.isLoading)
        }
       
    }
    
    private func loadProducts() {
        Apphud.paywallsDidLoadCallback { [self] (paywalls) in
            let paywall = paywalls.first(where: { $0.identifier == "explorer" })
            if let products = paywall?.products, products.count > 0 {
                selectProduct = products.first
            }
        }
    }
    
    func formatPrice(skProduct: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        return formatter.string(from: skProduct.price) ?? ""
    }
}
