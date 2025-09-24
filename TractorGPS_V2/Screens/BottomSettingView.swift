import SwiftUI

struct PreSettingsView: View {
    var farmingType: String
    var trackWidth: String
    var onDecrease: () -> Void
    var onIncrease: () -> Void
    var onStart: () -> Void
    var onSetTarget: () -> Void
    @Binding var operationType: OperationType
    @ObservedObject var locationManager: ManagerLocation
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        VStack(spacing: 0) {
            
            // Tiêu đề PRE - SETTINGS
            Text("PRE - SETTINGS").font(AppFonts.regular(size: 13)).foregroundColor(AppTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                .padding(.leading, 20)
            
            // Khung chính
            VStack(spacing: 0) {
                
               
                
                HStack {
                    HStack{
                        Image("icType")
                        Text("Farming Type").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                    }
                    Spacer()
                    Menu {
                        
                        ForEach(OperationType.allCases, id: \.self) { type in
                            Button(action: {
                                locationManager.currentOperation = type
                                operationType = type
                            }) {
                                HStack {
                                    if operationType.rawValue == type.rawValue{
                                        
                                        Text("✓ " + type.rawValue).font(AppFonts.regular(size: 17))
                                    }
                                    else{
                                        Text("‎ ‎ ‎ ‎ " + type.rawValue).font(AppFonts.regular(size: 17))
                                    }
                                    Spacer()
                                    Image(systemName: type.icon)
                                }
                            }
                        }
                    } label: {
                        HStack{
                            Text(operationType.rawValue).font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textTertiary)
                            Image("dropdown") .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    
                    
                    
                }
                .padding()
                
                Divider()
                // Farming Type
                HStack {
                    VStack(spacing: 2){
                        HStack{
                            Image("trackingwidth")
                            Text("Coverage").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        HStack{
                            Text("0%")
                                .font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textTertiary)
                            Spacer()
                        }
                        
                    }
                    
                    Spacer()
                    
                    Button(action: onSetTarget) {
                        HStack{
                            Text("Set Target").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textTertiary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    
                }
                .padding()
                
                Divider()
                
                // Track Width
                HStack {
                    VStack(spacing: 2){
                        HStack{
                            Image("icTracking")
                            Text("Track Width").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        HStack{
                            Text(trackWidth)
                                .font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.primary).multilineTextAlignment(.leading)
                            Spacer()
                        }
                        
                    }
                    
                    Spacer()
                    VStack{
                        HStack(spacing: 5) {
                            ScaleButton(icon: "Decrement") {
                                onDecrease()
                            }.padding(.leading, 10)
                            Divider().frame(height: 24).padding(.vertical, 2)
                            ScaleButton(icon: "Increment") {
                                onIncrease()
                            }.padding(.trailing, 10)
                        }
                        .background(UITraitCollection.current.userInterfaceStyle == .dark ? Color(hex: "787880").opacity(0.24) : Color(hex: "787880").opacity(0.12))
                        .clipShape(Capsule())
                        
                    }
                  
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .background(UITraitCollection.current.userInterfaceStyle == .dark ? Color(hex: "1C1C1E") : Color(hex: "F2F2F7"))
            .cornerRadius(12)
            Button {
                onStart()
            } label: {
                Image("start_dark")
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .themeAware()
    }
}
