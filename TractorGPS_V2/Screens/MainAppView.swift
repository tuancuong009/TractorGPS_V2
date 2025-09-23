//
//  MainAppView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//
import SwiftUI

enum MainTab {
    case map
    case history
    case settings
}

struct MainAppView: View {
    @State private var selectedTab: MainTab = .map
    @State private var isStart = false   // tShow Hide Tabbar
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Nội dung theo tab
            Group {
                switch selectedTab {
                case .map:
                    ContentView(isStart: $isStart)  // truyền xuống ContentView
                case .history:
                    HistoryView(isStart: $isStart)
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background.ignoresSafeArea())
            
            // Custom TabBar (ẩn khi Start)
            if !isStart {
                VStack(spacing: 0){
                    Color.clear.frame(height: 10)
                    CustomTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 12)
                }
                .background(AppTheme.surface)
                .transition(.move(edge: .bottom))   // hiệu ứng ẩn/hiện
                .animation(.easeInOut, value: isStart)
            }
        }
        .themeAware()
    }
}


struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        ZStack {
            // Capsule Border
            Image("bg_tabbar")
            HStack(spacing: 0) {
                tabButton(tab: .map, title: "Map", select: "tab_home", selected: "tab_home1")
                tabButton(tab: .history, title: "History", select: "tab_history", selected: "tab_history1")
                tabButton(tab: .settings, title: "Settings", select: "tab_setting", selected: "tab_setting1")
            }
            .padding(6)
            .padding(.horizontal, 30)
            .padding(.top, 2)
        }
       
    }
    
    private func tabButton(tab: MainTab, title: String, select: String, selected: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(selectedTab == tab ? selected : select)
                Text(title)
                    .font(AppFonts.medium(size: 10))
                    .foregroundColor(selectedTab == tab ? AppTheme.primary : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity) // 👉 full chiều ngang
            .padding(.vertical, 8)
            .background(
                Group {
                    if selectedTab == tab {
                        AppTheme.surfaceSecondary
                            .clipShape(Capsule())
                    } else {
                        Color.clear
                    }
                }
            )
        }
    }
}



#Preview {
    MainAppView()
}


