//
//  MapRepresentable.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 17/9/25.
//

import UIKit
import Foundation
import MapKit
import SwiftUI

struct MapRepresentable: UIViewRepresentable {
    @AppStorage(AppStorageKeys.polygonColorHex) private var polygonColorHex: String = "#22642E"
    @Binding var region: MKCoordinateRegion
    @Binding var points: [CLLocationCoordinate2D]
    @Binding var mapType: MKMapType
    var focusUser: Bool
    var onAddPoint: ((CLLocationCoordinate2D) -> Void)?
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapRepresentable
        init(_ parent: MapRepresentable) { self.parent = parent }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor.init(hex: parent.polygonColorHex)
                renderer.fillColor = UIColor.init(hex: parent.polygonColorHex)?.withAlphaComponent(0.3)
                renderer.lineWidth = 2
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
                view?.backgroundColor = UIColor.init(hex: parent.polygonColorHex)
                view?.layer.borderWidth = 3.0
                view?.layer.borderColor = UIColor.white.cgColor
                view?.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
                view?.layer.shadowOpacity = 1
                view?.layer.shadowOffset = CGSize(width: 0, height: 4) // X=0, Y=4
                view?.layer.shadowRadius = 8 / 2
            } else {
                view?.annotation = annotation
            }
            return view
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            parent.onAddPoint?(coordinate)
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false) // chỉ set 1 lần khi tạo
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tap)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
        
        if focusUser, let userLocation = uiView.userLocation.location {
            uiView.setCenter(userLocation.coordinate, animated: true)
        }
        
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        if points.count > 2 {
            let polygon = MKPolygon(coordinates: points, count: points.count)
            uiView.addOverlay(polygon)
        }
        
        for p in points {
            let ann = MKPointAnnotation()
            ann.coordinate = p
            uiView.addAnnotation(ann)
        }
    }

}

