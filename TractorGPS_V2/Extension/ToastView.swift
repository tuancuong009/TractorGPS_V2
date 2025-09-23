import SwiftUI

struct ToastView: View {
    let message: String
    let systemImage: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(AppFonts.semiBold(size: 16))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}
