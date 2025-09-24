//
//  SettingsView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 18/9/25.
//


import SwiftUI
import StoreKit
import ApphudSDK
struct SettingsView: View {
    @StateObject private var locationManager = ManagerLocation()
    @StateObject private var safariManager = SafariManager.shared
    @Environment(\.safeAreaInsets) var safeInsets
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage(AppStorageKeys.themeMode) private var themeMode: String = "System"
    @StateObject private var manager = ShareAndMailManager()
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(destination: SettingMapView(locationManager: locationManager)) {
                        HStack(spacing: 20){
                            Image("st_map")
                            Text("Map").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    NavigationLink(destination: SettingUnitView()) {
                        HStack(spacing: 20){
                            Image("st_unit")
                            Text("Units").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    
                    HStack(spacing: 20){
                        HStack(spacing: 20){
                            Image("st_map")
                            Text("Theme").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                themeMode = "System"
                                themeManager.setThemeMode("System")
                            }) {
                                HStack{
                                    Text("System").font(AppFonts.regular(size: 17))
                                    Spacer()
                                    if themeMode == "System" { Image("tick2") }
                                }
                            }
                            Button(action: {
                                themeMode = "Light"
                                themeManager.setThemeMode("Light")
                            }) {
                                HStack{
                                    Text("Light").font(AppFonts.regular(size: 17))
                                    Spacer()
                                    if themeMode == "Light" { Image("tick2") }
                                }
                            }
                            Button(action: {
                                themeMode = "Dark"
                                themeManager.setThemeMode("Dark")
                            }) {
                                HStack{
                                    Text("Dark").font(AppFonts.regular(size: 17))
                                    Spacer()
                                    if themeMode == "Dark" { Image("tick2") }
                                }
                            }
                        } label: {
                            HStack{
                                Text(themeMode).font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textTertiary)
                                Image("dropdown") .foregroundColor(AppTheme.primary)
                            }
                        }
                    }.padding(.vertical, 4)
                    
                }.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                Section {
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }) {
                        HStack(spacing: 20){
                            Image("st_rate")
                            Text("Rate our App").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        
                        let text = "Enjoying the app? Help others boost their productivity and efficiency by sharing it. Tap below to send a personalized link to your friends and colleagues."
                        // Optionally include App Store link:
                        let appLink = URL(string: "https://apps.apple.com/us/app/\(AppSettings.APP_ID)")!
                        manager.share([text, appLink])
                        
                    }) {
                        HStack(spacing: 20){
                            Image("st_share")
                            Text("Share App").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    Button(action: {
                        
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
                        
                    }) {
                        HStack(spacing: 20){
                            Image("st_contactus")
                            Text("Contact us").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    
                }.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                Section {
                    
                    Button(action: {}) {
                        HStack(spacing: 20){
                            Image("st_restore")
                            Text("Restore Purchases").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                }.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                Section {
                    Button(action: {
                        safariManager.open(AppSettings.PRIVACY)
                    }) {
                        HStack(spacing: 20){
                            Image("st_privacy")
                            Text("Privacy Policy").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        safariManager.open(AppSettings.TERMS)
                    }) {
                        HStack(spacing: 20){
                            Image("st_term")
                            Text("Terms of Service").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                        }.padding(.vertical, 4)
                    }
                    
                }.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                Section(footer:
                            VStack(alignment: .center, spacing: 4) {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,  let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        Text("Version \(version) (\(build))")
                            .font(AppFonts.regular(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    
                    Text("ID: \(Apphud.userID())")
                        .font(AppFonts.regular(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Color.clear.frame(height: 30)
                    
                }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .padding(.horizontal)
                ) {
                    
                }
                
            }
            .listSectionSpacing(25)
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
          
            .padding(.bottom, safeInsets.bottom + 62)
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
            // Present share sheet
            .sheet(isPresented: $manager.presentShareSheet, onDismiss: {
                manager.shareItems = []
            }) {
                ActivityView(activityItems: manager.shareItems, completion: nil)
            }
            .environmentObject(manager)
            .sheet(item: $safariManager.safariURL) { safariURL in
                SafariView(url: safariURL.url)
            }
        }
        
    }
}
