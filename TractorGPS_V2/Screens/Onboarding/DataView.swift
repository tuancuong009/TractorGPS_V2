//
//  DataView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//
import SwiftUI

struct DataView: View {
    var onNext: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save up to 12% of your costs with FieldTrac vs on your own")
                .font(AppFonts.bold(size: 28)).foregroundColor(AppTheme.textPrimary).padding(.top, 20)
            
            Image("chart")
            let highlight = "saves up to 12% of your costs"
            if let attr = makeHighlightedAttributedString(full: "“Data shows that FieldTrac saves up to 12% of your costs on fuel and input costs with precise, optimized guidance.”", highlight: highlight) {
                Text(attr)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(Color.clear)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: onNext) {
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
        }
        .padding(20)
        .background(AppTheme.backgroundQuestion.ignoresSafeArea())
        .themeAware()
    }
    
    private func makeHighlightedAttributedString(full: String, highlight: String) -> AttributedString? {
        let ns = NSMutableAttributedString(string: full, attributes: [
            .font: UIFont(name: "SFProText-Light", size: 16) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(AppTheme.textPrimary)
        ])
        
        let range = (full as NSString).range(of: highlight)
        if range.location != NSNotFound {
            ns.addAttributes([
                .font: UIFont(name: "SFProText-Medium", size: 16) ?? UIFont.systemFont(ofSize: 14),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor(AppTheme.primary)
            ], range: range)
        }
        
        return try? AttributedString(ns)
    }
}
