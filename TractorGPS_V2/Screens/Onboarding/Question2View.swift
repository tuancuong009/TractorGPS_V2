//
//  Question2View.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI

struct Question2View: View {
    var onNext: () -> Void
    @EnvironmentObject var vm: SetupFlowViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage(AppStorageKeys.onboardingFieldSize) private var persistedFieldSize: String?
    @State private var selected: String? = "Small (<10 acres)"
    @State private var scale: [String: CGFloat] = [:] // lưu scale theo từng option
    
    let options = ["Small (<10 acres)", "Medium (10–50 acres)", "Large (>50 acres)"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 5){
                Text("Question").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.textTertiary)
                Text("2/3").font(AppFonts.regular(size: 15)).foregroundColor(AppTheme.primary)
                Spacer()
            }
            .padding(.top, 20)
            
            Text("How large are your fields?")
                .font(AppFonts.bold(size: 28))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    // bounce animation
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        scale[option] = 1.05
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale[option] = 1.0
                        }
                    }
                    
                    selected = option
                }) {
                    HStack (spacing: 10) {
                        if selected == option {
                            Image("ticked")
                        } else {
                            Image("untick")
                        }
                        
                        Text(option)
                            .font(AppFonts.regular(size: 17))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(selected == option ? AppTheme.primary : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(scale[option] ?? 1.0)
                    .zIndex(selected == option ? 1 : 0)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 2) //
            }
            
            Spacer()
            
            Button(action: {
                vm.question2 = selected
                persistedFieldSize = selected
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
            .disabled(selected == nil)
        }
        .padding(20)
        .background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
    }
}
