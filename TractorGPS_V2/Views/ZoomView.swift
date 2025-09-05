//
//  ZoomView.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct ZoomView: View {
    @Binding var region: MKCoordinateRegion

    var body: some View {
        VStack(spacing: 10) {
            Button(action: zoomIn) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }

            Button(action: zoomOut) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
    }

    private func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    private func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }
}
