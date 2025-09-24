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
    @AppStorage(AppStorageKeys.polygonColorHex) private var polygonColorHex: String = "#22642E"
    @ObservedObject var locationManager: ManagerLocation
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MKUserTrackingMode
    @Binding var mapType: MKMapType
    @Binding var points: [CLLocationCoordinate2D]
    
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
        DispatchQueue.main.async {
            // Cập nhật region & loại bản đồ
            view.setRegion(region, animated: true)
            view.mapType = mapType
            
            // Giữ nguyên các overlay khác, chỉ xoá polygon
            let polygonOverlays = view.overlays.compactMap { $0 as? MKPolygon }
            view.removeOverlays(polygonOverlays)
            
            // Giữ nguyên annotation UserLocation, xoá point annotation
            let pointAnnotations = view.annotations.filter { !($0 is MKUserLocation) }
            view.removeAnnotations(pointAnnotations)
            
            // Triangle position indicator
            let triangleOverlays = view.overlays.compactMap { $0 as? TriangleIndicator }
            view.removeOverlays(triangleOverlays)
            if let location = locationManager.location {
                let heading = locationManager.heading?.trueHeading ?? 90
                let triangle = TriangleIndicator(
                    center: location.coordinate,
                    heading: heading,
                    color: locationManager.currentOperation.color
                )
                view.addOverlay(triangle)
            }
            
            // Guidance lines
            if !locationManager.guidanceLines.isEmpty {
                for i in stride(from: 0, to: locationManager.guidanceLines.count, by: 2) {
                    guard i + 1 < locationManager.guidanceLines.count else { break }
                    let pts = [locationManager.guidanceLines[i], locationManager.guidanceLines[i + 1]]
                    let guidanceLine = GuidanceLineOverlay(coordinates: pts, count: 2)
                    
                    if let currentLocation = locationManager.location?.coordinate {
                        let distance = locationManager.distanceFromPointToLine(
                            point: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                            lineStart: CLLocation(latitude: pts[0].latitude, longitude: pts[0].longitude),
                            lineEnd: CLLocation(latitude: pts[1].latitude, longitude: pts[1].longitude)
                        )
                        guidanceLine.isActiveLine = abs(distance) < locationManager.implementWidth / 2
                    }
                    
                    view.addOverlay(guidanceLine)
                }
            }
            
            // Tracking sessions
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
            
            // Polygon từ points
            if points.count > 2 {
                let polygon = MKPolygon(coordinates: points, count: points.count)
                view.addOverlay(polygon)
            }
            
            // Annotation từng point
            for p in points {
                let ann = MKPointAnnotation()
                ann.coordinate = p
                view.addAnnotation(ann)
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
            }
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor(hex: parent.polygonColorHex)
                renderer.fillColor = UIColor(hex: parent.polygonColorHex)?.withAlphaComponent(0.3)
                renderer.lineWidth = 2
                return renderer
            } else if let guidanceLine = overlay as? GuidanceLineOverlay {
                let renderer = MKPolylineRenderer(overlay: guidanceLine)
                if guidanceLine.isActiveLine {
                    renderer.strokeColor = .green
                    renderer.lineWidth = 3
                } else {
                    renderer.strokeColor = .red
                    renderer.lineWidth = 1
                }
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let id = "point"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
                view?.layer.cornerRadius = 8
                view?.backgroundColor = UIColor(hex: parent.polygonColorHex)
                view?.layer.borderWidth = 3.0
                view?.layer.borderColor = UIColor.white.cgColor
                view?.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
                view?.layer.shadowOpacity = 1
                view?.layer.shadowOffset = CGSize(width: 0, height: 4)
                view?.layer.shadowRadius = 4
            } else {
                view?.annotation = annotation
            }
            return view
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
