//
//  TriangleIndicator+Custom.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import MapKit
import SwiftUI

class TriangleIndicator: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let heading: Double
    let color: UIColor
    private let length: Double = 3.5 // Length of the triangle
    private let width: Double = 4.0 // Width of the triangle base

    init(center: CLLocationCoordinate2D, heading: Double, color: UIColor) {
        coordinate = center
        self.heading = heading
        self.color = color

        // Create bounding rect
        let topLeft = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: center.latitude + 0.0001,
                longitude: center.longitude - 0.0001
            )
        )
        let bottomRight = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: center.latitude - 0.0001,
                longitude: center.longitude + 0.0001
            )
        )

        boundingMapRect = MKMapRect(
            x: min(topLeft.x, bottomRight.x),
            y: min(topLeft.y, bottomRight.y),
            width: abs(topLeft.x - bottomRight.x),
            height: abs(topLeft.y - bottomRight.y)
        )
    }

    func getTriangleCoordinates() -> [CLLocationCoordinate2D] {
        // Convert heading to radians and adjust direction
        let angle = (-heading + 90) * .pi / 180.0
        let metersPerLat = 111_111.0
        let metersPerLong = metersPerLat * cos(coordinate.latitude * .pi / 180.0)

        // Calculate three points for isosceles triangle
        let points: [(Double, Double)] = [
            // Front point (tip of the arrow)
            (length * cos(angle), length * sin(angle)),

            // Back left point
            ((-width / 2) * cos(angle - .pi / 2) + (-length / 2) * cos(angle),
             (-width / 2) * sin(angle - .pi / 2) + (-length / 2) * sin(angle)),

            // Back right point
            ((width / 2) * cos(angle - .pi / 2) + (-length / 2) * cos(angle),
             (width / 2) * sin(angle - .pi / 2) + (-length / 2) * sin(angle)),
        ]

        return points.map { x, y in
            let lat = coordinate.latitude + (y / metersPerLat)
            let lon = coordinate.longitude + (x / metersPerLong)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}

class TriangleOverlayRenderer: MKOverlayRenderer {
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let overlay = overlay as? TriangleIndicator else { return }

        // Convert coordinates to points using renderer's point(for:) method
        let points = overlay.getTriangleCoordinates().map { coordinate -> CGPoint in
            return self.point(for: MKMapPoint(coordinate))
        }

        context.setFillColor(overlay.color.withAlphaComponent(0.3).cgColor)
        context.setStrokeColor(overlay.color.cgColor)
        context.setLineWidth(2.0 / zoomScale)

        let path = CGMutablePath()
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.closeSubpath()

        context.addPath(path)
        context.drawPath(using: .fillStroke)
    }
}

class CustomOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let polygonPoints: [CLLocationCoordinate2D]
    let type: OperationType

    // Make these static functions accessible
    static func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        var heading = atan2(y, x) * 180 / .pi
        if heading < 0 {
            heading += 360
        }
        return heading
    }

    static func averageHeading(h1: Double, h2: Double) -> Double {
        var diff = h2 - h1
        if diff > 180 {
            diff -= 360
        } else if diff < -180 {
            diff += 360
        }
        var avg = h1 + diff / 2
        if avg < 0 {
            avg += 360
        } else if avg >= 360 {
            avg -= 360
        }
        return avg
    }

    init(from: TrackPoint, to: TrackPoint, prevHeading: Double?, nextHeading: Double?) {
        type = from.operationType

        // Calculate width points perpendicular to movement direction
        let halfWidth = from.implementWidth / 2.0

        // Calculate heading based on previous, current, and next points
        let fromHeading: Double
        let toHeading: Double

        if let prev = prevHeading {
            // Smooth the transition from previous segment
            fromHeading = CustomOverlay.averageHeading(h1: prev, h2: CustomOverlay.calculateHeading(from: from.coordinate, to: to.coordinate))
        } else {
            fromHeading = CustomOverlay.calculateHeading(from: from.coordinate, to: to.coordinate)
        }

        if let next = nextHeading {
            // Smooth the transition to next segment
            toHeading = CustomOverlay.averageHeading(h1: CustomOverlay.calculateHeading(from: from.coordinate, to: to.coordinate), h2: next)
        } else {
            toHeading = CustomOverlay.calculateHeading(from: from.coordinate, to: to.coordinate)
        }

        // Calculate width points for both positions using smoothed headings
        func getWidthPoints(at coord: CLLocationCoordinate2D, heading: Double) -> (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) {
            let angle = heading * .pi / 180.0
            let perpAngle = angle + .pi / 2

            let metersPerLat = 111_111.0
            let metersPerLong = metersPerLat * cos(coord.latitude * .pi / 180.0)

            let latOffset = (halfWidth / metersPerLat) * cos(perpAngle)
            let longOffset = (halfWidth / metersPerLong) * sin(perpAngle)

            let left = CLLocationCoordinate2D(
                latitude: coord.latitude + latOffset,
                longitude: coord.longitude + longOffset
            )

            let right = CLLocationCoordinate2D(
                latitude: coord.latitude - latOffset,
                longitude: coord.longitude - longOffset
            )

            return (left, right)
        }

        // Get width points using smoothed headings
        let fromPoints = getWidthPoints(at: from.coordinate, heading: fromHeading)
        let toPoints = getWidthPoints(at: to.coordinate, heading: toHeading)

        // Create polygon using both sets of width points
        polygonPoints = [
            fromPoints.left,
            fromPoints.right,
            toPoints.right,
            toPoints.left,
        ]

        // Calculate center and bounding rect
        let latitudes = polygonPoints.map { $0.latitude }
        let longitudes = polygonPoints.map { $0.longitude }

        coordinate = CLLocationCoordinate2D(
            latitude: (latitudes.max()! + latitudes.min()!) / 2,
            longitude: (longitudes.max()! + longitudes.min()!) / 2
        )

        let topLeft = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: latitudes.max()!,
                longitude: longitudes.min()!
            )
        )
        let bottomRight = MKMapPoint(
            CLLocationCoordinate2D(
                latitude: latitudes.min()!,
                longitude: longitudes.max()!
            )
        )

        boundingMapRect = MKMapRect(
            x: min(topLeft.x, bottomRight.x),
            y: min(topLeft.y, bottomRight.y),
            width: abs(topLeft.x - bottomRight.x),
            height: abs(topLeft.y - bottomRight.y)
        )
    }
}

class CustomOverlayRenderer: MKOverlayRenderer {
    override func draw(_: MKMapRect, zoomScale _: MKZoomScale, in context: CGContext) {
        guard let overlay = overlay as? CustomOverlay else { return }

        let points = overlay.polygonPoints.map { coordinate -> CGPoint in
            let mapPoint = MKMapPoint(coordinate)
            return point(for: mapPoint)
        }

        guard points.count >= 4 else { return }

        // Draw filled polygon
        context.setFillColor(overlay.type.color.withAlphaComponent(0.3).cgColor)
        context.setStrokeColor(overlay.type.color.withAlphaComponent(0.5).cgColor)
        // context.setLineWidth(1.0 / zoomScale)

        let path = CGMutablePath()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()

        context.addPath(path)
        context.drawPath(using: .fillStroke)
    }
}

class GuidanceLineOverlay: MKPolyline {
    var isActiveLine = false
}
