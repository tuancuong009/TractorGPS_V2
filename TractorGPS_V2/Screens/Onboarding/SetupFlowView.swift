import SwiftUI

enum SetupStep: Int, CaseIterable {
    case question1, question2, question3, data, rating, loadingView, doneSetup
}

struct SetupFlowView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var step: SetupStep = .question1
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack{
            AppTheme.backgroundQuestion.ignoresSafeArea()
            if step == .loadingView || step == .doneSetup{
                VStack{
                    if step == .loadingView{
                        LoadingSetupView {
                            goNext()
                        }
                    }
                    else  if step == .doneSetup{
                        DoneSetupView()
                    }
                }.navigationBarHidden(true)
            }
            else{
                VStack {
                    SetupToolbar(
                        progress: Double(step.rawValue + 1) / Double(SetupStep.allCases.count - 2),
                        onBack: { goBack() }
                    )
                    
                    Spacer()
                    
                    switch step {
                    case .question1: Question1View(onNext: goNext)
                    case .question2: Question2View(onNext: goNext)
                    case .question3: Question3View(onNext: goNext)
                    case .data:      DataView(onNext: goNext)
                        
                    case .rating:    RatingView(onNext: { goNext() })
                    case .loadingView:
                        EmptyView()
                    case .doneSetup:
                        EmptyView()
                    }
                    
                    Spacer()
                }
                .navigationBarHidden(true)
            }
          
        }
      
    }
    
    private func goNext() {
        if let next = SetupStep(rawValue: step.rawValue + 1) {
            print(step.rawValue)
            print(SetupStep.allCases.count)
            step = next
        }
    }
    
    private func goBack() {
        if let prev = SetupStep(rawValue: step.rawValue - 1) {
            step = prev
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
