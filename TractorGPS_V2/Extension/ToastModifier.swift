import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let systemImage: String
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if isShowing {
                    ToastView(message: message,
                              systemImage: systemImage,
                              backgroundColor: backgroundColor)
                        .transition(.move(edge: .top).combined(with: .opacity)) // ⬅️ trượt + mờ dần
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
                }
                Spacer()
            }
            .padding(.top, 50)
            .zIndex(1)
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>,
               message: String,
               systemImage: String,
               backgroundColor: Color) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing,
                                    message: message,
                                    systemImage: systemImage,
                                    backgroundColor: backgroundColor))
    }
}
