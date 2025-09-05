//
//  MapViewKit.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapViewKit: UIViewRepresentable {
    @ObservedObject var locationManager: ManagerLocation
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MKUserTrackingMode
    @Binding var mapType: MKMapType
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context _: Context) {
        view.setRegion(region, animated: true)
        view.removeOverlays(view.overlays)
        view.mapType = mapType // Add this line
        
        if let location = locationManager.location {
            let heading = locationManager.heading?.trueHeading ?? 0
            
            let camera = MKMapCamera(
                lookingAtCenter: location.coordinate, // Always center on actual location
                fromDistance: view.camera.centerCoordinateDistance,
                pitch: 0,
                heading: heading
            )
            view.setCamera(camera, animated: false)
        }
        
        // Add triangle position indicator
        if let location = locationManager.location {
            let heading = locationManager.heading?.trueHeading ?? 90
            let triangle = TriangleIndicator(
                center: location.coordinate,
                heading: heading,
                color: locationManager.currentOperation.color
            )
            view.addOverlay(triangle)
        }
        
        if !locationManager.guidanceLines.isEmpty {
            for i in stride(from: 0, to: locationManager.guidanceLines.count, by: 2) {
                guard i + 1 < locationManager.guidanceLines.count else { break }
                let points = [locationManager.guidanceLines[i], locationManager.guidanceLines[i + 1]]
                let guidanceLine = GuidanceLineOverlay(coordinates: points, count: 2)
                
                // Set active status based on distance
                if let currentLocation = locationManager.location?.coordinate {
                    let distance = locationManager.distanceFromPointToLine(
                        point: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                        lineStart: CLLocation(latitude: points[0].latitude, longitude: points[0].longitude),
                        lineEnd: CLLocation(latitude: points[1].latitude, longitude: points[1].longitude)
                    )
                    guidanceLine.isActiveLine = abs(distance) < locationManager.implementWidth / 2
                }
                
                view.addOverlay(guidanceLine)
            }
        }
        
        for sessionPoints in locationManager.trackingSessions {
            guard sessionPoints.count >= 2 else { continue }
            
            for i in 1 ..< sessionPoints.count {
                let previous = sessionPoints[i - 1]
                let current = sessionPoints[i]
                
                let prevHeading: Double? = i > 1 ?
                CustomOverlay.calculateHeading(from: sessionPoints[i - 2].coordinate, to: previous.coordinate) : nil
                let nextHeading: Double? = i < sessionPoints.count - 1 ?
                CustomOverlay.calculateHeading(from: current.coordinate, to: sessionPoints[i + 1].coordinate) : nil
                
                let overlay = CustomOverlay(
                    from: previous,
                    to: current,
                    prevHeading: prevHeading,
                    nextHeading: nextHeading
                )
                view.addOverlay(overlay)
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewKit
        
        init(_ parent: MapViewKit) {
            self.parent = parent
        }
        
        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let triangle = overlay as? TriangleIndicator {
                return TriangleOverlayRenderer(overlay: triangle)
            } else if let customOverlay = overlay as? CustomOverlay {
                return CustomOverlayRenderer(overlay: customOverlay)
            } else if let guidanceLine = overlay as? GuidanceLineOverlay {
                let renderer = MKPolylineRenderer(overlay: guidanceLine)
                if guidanceLine.isActiveLine {
                    renderer.strokeColor = .green
                    renderer.lineWidth = 3
                } else {
                    renderer.strokeColor = .red
                    renderer.lineWidth = 1
                    // renderer.lineDashPattern = [4, 4]
                }
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
