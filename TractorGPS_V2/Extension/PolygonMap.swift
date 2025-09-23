//
//  PolygonMap.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 19/9/25.
//
import SwiftUI
import MapKit

struct PolygonMap: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var coordinates: [CLLocationCoordinate2D]
    @AppStorage(AppStorageKeys.polygonColorHex) private var polygonColorHex: String = "#22642E"
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PolygonMap
        init(_ parent: PolygonMap) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor.init(hex: parent.polygonColorHex)
                renderer.fillColor = UIColor.init(hex: parent.polygonColorHex)?.withAlphaComponent(0.1)
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
        
       
    }
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        
        if region.center.latitude == 0{
            mapView.showsUserLocation = true
        }
        else{
            mapView.setRegion(region, animated: false)
        }
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        print("PolygonMap - Coordinates count: \(coordinates.count)")
        print("PolygonMap - Region: \(region)")
        
        // Update map region
        if region.center.latitude == 0{
            
        }
        else{
            uiView.setRegion(region, animated: false)
        }
        //
        
        if coordinates.count > 2 {
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polygon)
            print("PolygonMap - Added polygon with \(coordinates.count) points")
        }
        
        for p in coordinates {
            let ann = MKPointAnnotation()
            ann.coordinate = p
            uiView.addAnnotation(ann)
        }
        print("PolygonMap - Added \(coordinates.count) annotations")
    }
}
