//
//  ReasonsView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//

import SwiftUI
import UIKit

struct ReasonsView: View {
    @State private var visibleReasons: [Bool] = Array(repeating: false, count: 7)
    @State private var showNextButton = false
    @EnvironmentObject var themeManager: ThemeManager
    
    private let reasons = [
        "GPS ensures no missed spots or overlaps.",
        "Saves fuel and reduces input waste.",
        "Improves crop coverage and health.",
        "“Data shows that Tractor GPS saves up to 12% of your costs on fuel and input costs with precise, optimized guidance.”",
        "Works easily with just your phone.",
        "Cheaper than traditional GPS systems.",
        "Perfect for spraying, fertilizing, and plowing."
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reasons why you should use\nFieldTrac")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    
                    ForEach(reasons.indices, id: \.self) { index in
                        reasonRow(index: index)
                            .blur(radius: visibleReasons[index] ? 0 : 10)
                            .animation(.easeOut(duration: 1.0), value: visibleReasons[index])
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .center) // 🔑
                
                if showNextButton {
                    NavigationLink(destination: SetupFlowView().environmentObject(themeManager)) {
                        Text("Next")
                            .font(AppFonts.medium(size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .transition(.opacity)
                    .animation(.easeIn, value: showNextButton)
                }
            }
        }
        .onAppear { animateReasons() }
        .toolbar(.hidden, for: .navigationBar)
        .themeAware()
    }


    
    @ViewBuilder
    private func reasonRow(index: Int) -> some View {
        HStack(alignment: .top, spacing: 8) {
            
            
            if index == 3 {
                // Highlighted quote with substring styled differently
                let full = reasons[index]
                let highlight = "saves up to 12% of your costs"
                if let attr = makeHighlightedAttributedString(full: full, highlight: highlight) {
                    Text(attr)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(AppTheme.surfaceSecondary.opacity(0.3))
                        .cornerRadius(8)
                } else {
                    
                    Text(full)
                        .font(AppFonts.regular(size: 17))
                        .padding()
                        .background(AppTheme.surfaceSecondary.opacity(0.3))
                        .cornerRadius(8)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.textPrimary)
                Text(reasons[index])
                    .font(AppFonts.regular(size: 17))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
        }
    }
    
    /// build NSMutableAttributedString then convert to AttributedString (safer for compiler)
    private func makeHighlightedAttributedString(full: String, highlight: String) -> AttributedString? {
        let ns = NSMutableAttributedString(string: full, attributes: [
            .font: UIFont(name: "SFProText-Light", size: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(AppTheme.textPrimary)
        ])
        
        let range = (full as NSString).range(of: highlight)
        if range.location != NSNotFound {
            ns.addAttributes([
                .font: UIFont(name: "SFProText-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor(AppTheme.primary)
            ], range: range)
        }
        
        return try? AttributedString(ns)
    }
    
    private func animateReasons() {
        for i in reasons.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 2.0) {
                withAnimation {
                    visibleReasons[i] = true
                }
                if i == reasons.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showNextButton = true
                        }
                    }
                }
            }
        }
    }
}

struct ReasonsView_Previews: PreviewProvider {
    static var previews: some View {
        ReasonsView()
    }
}
