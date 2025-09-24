import MapKit
import SwiftUI

struct ButtonTrackView: View {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var region: MKCoordinateRegion
    @Binding var operationType: OperationType
    var onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Padding left
            if locationManager.isTracking{
                Color.clear.frame(width: 38, height: 76)
            }
            else{
                Color.clear.frame(width: 1, height: 76)
            }
            
            // Resume / Pause button
            resumePauseButton
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: locationManager.isTracking)
            
            // Stop button only when tracking is off
            if !locationManager.isTracking {
                stopButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: locationManager.isTracking)
            }
            
            // Padding right
            if locationManager.isTracking{
                Color.clear.frame(width: 38, height: 76)
            }else{
                Color.clear.frame(width: 1, height: 76)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Resume / Pause Button
    private var resumePauseButton: some View {
        Button(action: {
            withAnimation {
                locationManager.toggleTracking()
                if locationManager.isTracking { zoomToUser() }
            }
        }) {
            HStack {
                Image(systemName: locationManager.isTracking ? "pause.fill" : "play.fill")
                    .font(AppFonts.semiBold(size: 20))
                    .foregroundColor(.white)
                Text(locationManager.isTracking ? "Pause" : "Resume")
                    .foregroundColor(.white)
                    .font(AppFonts.semiBold(size: 20))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(locationManager.isTracking ? Color(hex: "0088FF") : Color(hex: "00B846"))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Stop Button
    private var stopButton: some View {
        Button(action: {
            print("Stop tapped")
            withAnimation {
                onStop()
            }
        }) {
            Image("btn_stop")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .frame(width: 76, height: 76)
                .background(Color.red)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Zoom to user
    private func zoomToUser() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                )
            }
        }
    }
}
