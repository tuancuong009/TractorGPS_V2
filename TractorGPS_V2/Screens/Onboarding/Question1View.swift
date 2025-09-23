//
//  Question1View.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//
import SwiftUI

struct Question1View: View {
    var onNext: () -> Void
    @AppStorage(AppStorageKeys.onboardingWorkType) private var persistedWorkType: String?
    @State private var selectedOption: String? = "Field Plowing"
    @EnvironmentObject var vm: SetupFlowViewModel
    @EnvironmentObject var themeManager: ThemeManager
        let options = [
            ("Field Plowing", "icField", AppTheme.plowing),
            ("Seeding", "ic_seeding", AppTheme.seeding),
            ("Fertilizing", "ic_fertilizing", AppTheme.primary),
            ("Harvesting", "ic_harvesting", AppTheme.harvesting),
            ("Other", "ic_other", AppTheme.other)
        ]
        
    
    var body: some View {
        VStack() {
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    HStack(spacing: 5){
                        Text("Question").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.textTertiary)
                        Text("1/3").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.primary)
                        Spacer()
                    }.padding(.top, 20)
                    Text("What type of work do you want to optimize?")
                        .font(AppFonts.bold(size: 28)).foregroundColor(AppTheme.textPrimary).lineLimit(2)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(options, id: \.0) { option in
                            OptionCard(
                                title: option.0,
                                icon: option.1,
                                color: option.2,
                                isSelected: selectedOption == option.0
                            ) {
                                selectedOption = option.0
                            }
                            .padding(4)
                        }
                    }
                }
            }
            Spacer()
            
            Button(action: {
                print("Selected: \(selectedOption ?? "")")
                vm.question1 = selectedOption
                persistedWorkType = selectedOption
                onNext()
            }) {
                Text("Next")
                    .font(AppFonts.medium(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .padding(.bottom, 2)
            }
            .disabled(selectedOption == nil)
        }
        .padding(20)
        .background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
        
    }
}
struct OptionCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // trigger scale animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 1.05
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            HStack {
                VStack(alignment:.leading, spacing: 8) {
                    Image(icon)
                    
                    Text(title)
                        .font(AppFonts.regular(size: 17))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    ZStack {
                        if isSelected {
                            Image("ticked")
                                .resizable()
                                .frame(width: 20, height: 20)
                        } else {
                            Image("untick")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(AppTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: AppTheme.shadow.opacity(0.05), radius: 2, x: 0, y: 1)
            .scaleEffect(scale)
            .zIndex(isSelected ? 1 : 0)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle()) 
    }
}

