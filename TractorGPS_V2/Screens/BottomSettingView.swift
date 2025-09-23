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
                
                // Farming Type
                HStack {
                    VStack{
                        HStack{
                            Image("trackingwidth")
                            Text("Coverage").font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        HStack{
                            Text("0%")
                                .font(AppFonts.regular(size: 17)).foregroundColor(AppTheme.textPrimary)
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
                                HStack{
                                    Label(type.rawValue, systemImage: type.icon)
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
                
                // Track Width
                HStack {
                    VStack{
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
                    
                    HStack(spacing: 0) {
                        Button(action: onDecrease) {
                            Image("Decrement").foregroundColor(AppTheme.textPrimary)
                        }.frame(width: 46)
                        Divider().frame(height: 36).padding(.vertical, 5)
                        Button(action: onIncrease) {
                            Image("Increment").foregroundColor(AppTheme.textPrimary)
                        }.frame(width: 46)
                    }
                    .padding(.leading, 8)
                    .background(AppTheme.border.opacity(0.08))
                    .clipShape(Capsule())
                }
                .padding()
            }
            .background(AppTheme.surfaceSecondary)
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
