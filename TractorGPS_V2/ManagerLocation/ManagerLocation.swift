//
//  LocationManager.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import CoreLocation
import SwiftUI

class ManagerLocation: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var trackingSessions: [[TrackPoint]] = [[]]
    private var currentSessionIndex: Int = 0

    @Published var currentOperation: OperationType = .harvesting
    @Published var customWidth: Double?
    @Published var isTracking = false
    // Stats Properties
    @Published var currentSpeed: Double = 0
    @Published var totalDistance: Double = 0
    @Published var coveredArea: Double = 0
    public var lastLocation: CLLocation?

    // Guidance
    @Published var pointA: CLLocationCoordinate2D?
    @Published var pointB: CLLocationCoordinate2D?
    @Published var isSettingPointA = false
    @Published var isSettingPointB = false
    @Published var guidanceLines: [CLLocationCoordinate2D] = []
    @Published var distanceFromLine: Double = 0
    @Published var shouldTurnLeft = true
    @Published var implementWidth: Double = 16.0 // meters
    @Published var selectedPattern: GuidancePattern = .abLine

    // Authorization Status
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var didCheckPermission: Bool = false
    override init() {
        super.init()
        checkAuthorization()
        setupLocationManager()
    }

    // Helper to get current session's points
    private var currentSession: [TrackPoint] {
        get { trackingSessions[currentSessionIndex] }
        set { trackingSessions[currentSessionIndex] = newValue }
    }

    func generateGuidanceLines() {
        switch selectedPattern {
        case .abLine:
            generateABLines()

        case .curve:
            generateCurvedLines()
        }
    }

    // Add these new guidance methods
    func setPointA() {
        isSettingPointA = true
        pointA = nil
        pointB = nil
        guidanceLines.removeAll()
    }

    func setPointB() {
        guard pointA != nil else { return }
        isSettingPointB = true
    }

    private func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    var effectiveWidth: Double {
        print("customWidth--->", customWidth, currentOperation.defaultWidth)
        return customWidth ?? currentOperation.defaultWidth
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.activityType = .otherNavigation

        // Only start updates when authorized
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            didCheckPermission = true
        case .authorizedAlways, .authorizedWhenInUse:
            didCheckPermission = true
        @unknown default:
            didCheckPermission = true
        }
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    // Helper to check authorization easily
    var isLocationAuthorized: Bool {
        return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
  
    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            let heading = self.heading?.trueHeading ?? 0
            let speed = currentSpeed * 3.6
            let area = coveredArea / 4046.86

            TractorLiveActivityManager.shared.startActivity(
                heading: heading,
                speed: speed,
                area: area
            )

            // Start new session when tracking starts
            trackingSessions.append([])
            currentSessionIndex = trackingSessions.count - 1
            // Reset stats for new session
            totalDistance = 0
            coveredArea = 0
            lastLocation = nil
           
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard location.horizontalAccuracy <= 20 else { return }

        self.location = location
        currentSpeed = location.speed >= 0 ? location.speed : 0

        // Add AB line handling
        if isSettingPointA, pointA == nil {
            pointA = location.coordinate
            isSettingPointA = false
        }

        if isSettingPointB, pointB == nil {
            pointB = location.coordinate
            isSettingPointB = false
            generateGuidanceLines()
        }

        updateActiveGuidanceLine()

        if isTracking {
            addTrackPoint(at: location.coordinate)

            if let lastLocation = lastLocation {
                let distance = location.distance(from: lastLocation)
                totalDistance += distance
                coveredArea += distance * effectiveWidth
            }

            updateLiveActivity()
        }

        lastLocation = location
    }

    // MARK: - Authorization Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        checkAuthorization()
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        default:
            manager.stopUpdatingLocation()
            manager.stopUpdatingHeading()
        }
    }

    // Clear only the current session
    func clearCurrentSession() {
        trackingSessions[currentSessionIndex].removeAll()
        totalDistance = 0
        coveredArea = 0
        lastLocation = nil
    }

    // Clear all sessions
    func clearAllSessions() {
        trackingSessions = [[]]
        currentSessionIndex = 0
        totalDistance = 0
        coveredArea = 0
        lastLocation = nil
    }

    private func calculateParallelLine(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, offset: Double) -> [CLLocationCoordinate2D] {
        let bearing = calculateHeading(from: start, to: end) * .pi / 180
        let offsetLat = offset * cos(bearing + .pi / 2) / 111_320
        let offsetLon = offset * sin(bearing + .pi / 2) / (111_320 * cos(start.latitude * .pi / 180))

        let startOffset = CLLocationCoordinate2D(
            latitude: start.latitude + offsetLat,
            longitude: start.longitude + offsetLon
        )
        let endOffset = CLLocationCoordinate2D(
            latitude: end.latitude + offsetLat,
            longitude: end.longitude + offsetLon
        )

        return [startOffset, endOffset]
    }

    func calculateDeviationFromGuidanceLine(_ currentLocation: CLLocationCoordinate2D) {
        guard let pointA = pointA, let pointB = pointB else { return }

        let a = CLLocation(latitude: pointA.latitude, longitude: pointA.longitude)
        let b = CLLocation(latitude: pointB.latitude, longitude: pointB.longitude)
        let p = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)

        // Calculate distance from point to line
        let distance = distanceFromPointToLine(point: p, lineStart: a, lineEnd: b)
        distanceFromLine = abs(distance)
        shouldTurnLeft = distance > 0
    }

    func distanceFromPointToLine(point: CLLocation, lineStart: CLLocation, lineEnd: CLLocation) -> Double {
        let a = lineStart.coordinate
        let b = lineEnd.coordinate
        let p = point.coordinate

        let numerator = (b.longitude - a.longitude) * (a.latitude - p.latitude) -
            (a.longitude - p.longitude) * (b.latitude - a.latitude)
        let denominator = sqrt(pow(b.longitude - a.longitude, 2) + pow(b.latitude - a.latitude, 2))

        return numerator / denominator * 111_320 // Convert to meters
    }

    func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func addTrackPoint(at coordinate: CLLocationCoordinate2D) {
        let point = TrackPoint(
            coordinate: coordinate,
            timestamp: Date(),
            operationType: currentOperation,
            implementWidth: effectiveWidth
        )
        currentSession.append(point)
    }
}

extension ManagerLocation {
    private func generateCurvedLines() {
        guard let pointA = pointA, let pointB = pointB else { return }

        let controlPoint = calculateControlPoint(start: pointA, end: pointB)
        let baseCurve = generateBezierCurve(start: pointA, control: controlPoint, end: pointB)
        var allLines: [CLLocationCoordinate2D] = []

        // Generate parallel curves
        for i in -10 ... 10 {
            let offset = Double(i) * implementWidth
            let offsetCurve = generateOffsetCurve(points: baseCurve, distance: offset)
            allLines.append(contentsOf: offsetCurve)
        }

        guidanceLines = allLines
    }

    private func calculateControlPoint(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // Calculate midpoint
        let midLat = (start.latitude + end.latitude) / 2
        let midLon = (start.longitude + end.longitude) / 2

        // Offset the control point perpendicular to the line
        let heading = calculateHeading(from: start, to: end)
        let perpHeading = (heading + 90) * .pi / 180

        // Offset by 20% of the line length
        let distance = CLLocation(
            latitude: start.latitude,
            longitude: start.longitude
        ).distance(from: CLLocation(
            latitude: end.latitude,
            longitude: end.longitude
        ))
        let offset = distance * 0.2

        let offsetLat = offset * cos(perpHeading) / 111_320
        let offsetLon = offset * sin(perpHeading) / (111_320 * cos(midLat * .pi / 180))

        return CLLocationCoordinate2D(
            latitude: midLat + offsetLat,
            longitude: midLon + offsetLon
        )
    }

    private func generateBezierCurve(start: CLLocationCoordinate2D,
                                     control: CLLocationCoordinate2D,
                                     end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D]
    {
        var points: [CLLocationCoordinate2D] = []
        let steps = 50

        for i in 0 ... steps {
            let t = Double(i) / Double(steps)
            let point = quadraticBezierPoint(t: t, start: start, control: control, end: end)
            points.append(point)
        }

        return points
    }

    private func quadraticBezierPoint(t: Double,
                                      start: CLLocationCoordinate2D,
                                      control: CLLocationCoordinate2D,
                                      end: CLLocationCoordinate2D) -> CLLocationCoordinate2D
    {
        let x = pow(1 - t, 2) * start.longitude +
            2 * (1 - t) * t * control.longitude +
            pow(t, 2) * end.longitude

        let y = pow(1 - t, 2) * start.latitude +
            2 * (1 - t) * t * control.latitude +
            pow(t, 2) * end.latitude

        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }

    private func generateOffsetCurve(points: [CLLocationCoordinate2D], distance: Double) -> [CLLocationCoordinate2D] {
        var offsetPoints: [CLLocationCoordinate2D] = []

        for i in 0 ..< points.count - 1 {
            let current = points[i]
            let next = points[i + 1]

            let heading = calculateHeading(from: current, to: next)
            let perpHeading = (heading + 90) * .pi / 180

            let offsetLat = distance * cos(perpHeading) / 111_320
            let offsetLon = distance * sin(perpHeading) / (111_320 * cos(current.latitude * .pi / 180))

            offsetPoints.append(CLLocationCoordinate2D(
                latitude: current.latitude + offsetLat,
                longitude: current.longitude + offsetLon
            ))
        }

        return offsetPoints
    }
}

extension ManagerLocation {
    private func generateABLines() {
        guard let pointA = pointA, let pointB = pointB else { return }
        var lines: [CLLocationCoordinate2D] = []

        // Calculate heading
        let heading = calculateHeading(from: pointA, to: pointB)

        // Extend the line by 1000 meters (or any distance you want) in both directions
        let extensionDistance: Double = 1000 // meters

        // Calculate extended points
        let extendedStart = calculateEndPoint(
            from: pointA,
            heading: heading - 180, // Opposite direction
            distance: extensionDistance
        )

        let extendedEnd = calculateEndPoint(
            from: pointB,
            heading: heading,
            distance: extensionDistance
        )

        // Generate parallel lines using extended points
        let numberOfLines = 10 // Lines on each side
        for i in -numberOfLines ... numberOfLines {
            let offset = Double(i) * implementWidth
            let offsetPoints = calculateParallelLine(
                start: extendedStart,
                end: extendedEnd,
                offset: offset
            )
            lines.append(contentsOf: offsetPoints)
        }

        guidanceLines = lines
    }

    private func calculateEndPoint(from start: CLLocationCoordinate2D, heading: Double, distance: Double) -> CLLocationCoordinate2D {
        // Convert heading to radians
        let headingRadians = heading * .pi / 180

        // Calculate lat/lon changes
        // 111320 is approximately the number of meters per degree of latitude
        let distanceLat = distance * cos(headingRadians) / 111_320
        let distanceLon = distance * sin(headingRadians) / (111_320 * cos(start.latitude * .pi / 180))

        // Create new coordinate
        return CLLocationCoordinate2D(
            latitude: start.latitude + distanceLat,
            longitude: start.longitude + distanceLon
        )
    }

    private func generateAPlusLines() {
        guard let pointA = pointA, let pointB = pointB else { return }
        var lines: [CLLocationCoordinate2D] = []

        // First, generate AB lines
        lines.append(contentsOf: generateABParallelLines(pointA: pointA, pointB: pointB))

        // Then generate perpendicular lines
        let perpHeading = (calculateHeading(from: pointA, to: pointB) + 90).truncatingRemainder(dividingBy: 360)
        let perpDistance = 1000.0 // meters
        let perpEnd = calculateEndPoint(from: pointA, heading: perpHeading, distance: perpDistance)
        lines.append(contentsOf: generateABParallelLines(pointA: pointA, pointB: perpEnd))

        guidanceLines = lines
    }

    private func generateABParallelLines(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var lines: [CLLocationCoordinate2D] = []
        let numberOfLines = 10

        for i in -numberOfLines ... numberOfLines {
            let offset = Double(i) * implementWidth
            let offsetPoints = calculateParallelLine(start: pointA, end: pointB, offset: offset)
            lines.append(contentsOf: offsetPoints)
        }
        return lines
    }

    func updateActiveGuidanceLine() {
        guard let currentLocation = location?.coordinate else { return }
        var closestDistance = Double.infinity
        var closestLineStart: CLLocationCoordinate2D?
        var closestLineEnd: CLLocationCoordinate2D?

        // Check each guidance line
        for i in stride(from: 0, to: guidanceLines.count, by: 2) {
            guard i + 1 < guidanceLines.count else { break }

            let start = guidanceLines[i]
            let end = guidanceLines[i + 1]

            let distance = distanceFromPointToLine(
                point: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                lineStart: CLLocation(latitude: start.latitude, longitude: start.longitude),
                lineEnd: CLLocation(latitude: end.latitude, longitude: end.longitude)
            )

            if abs(distance) < abs(closestDistance) {
                closestDistance = distance // Keep the sign of the distance
                closestLineStart = start
                closestLineEnd = end
            }
        }

        // Update distance and turn direction
        if let start = closestLineStart, let end = closestLineEnd {
            distanceFromLine = abs(closestDistance)
            // If we're on the left side of the line (positive distance), turn right (shouldTurnLeft = false)
            // If we're on the right side of the line (negative distance), turn left (shouldTurnLeft = true)
            shouldTurnLeft = closestDistance < 0

            // Calculate current line index
            if let index = guidanceLines.firstIndex(where: { $0.latitude == start.latitude && $0.longitude == start.longitude }) {
                let guidanceLine = GuidanceLineOverlay(coordinates: [start, end], count: 2)
                guidanceLine.isActiveLine = abs(closestDistance) < implementWidth / 2
            }
        }
    }
}

// MARK: - Live Activity LocationManager Extension

extension ManagerLocation {
    private func updateLiveActivity() {
        guard isTracking else { return }
        // Find the closest guidance line and get its heading
        if let currentLocation = location?.coordinate {
            var closestDistance = Double.infinity
            var targetHeading: Double?

            // Check each guidance line
            for i in stride(from: 0, to: guidanceLines.count, by: 2) {
                guard i + 1 < guidanceLines.count else { break }

                let start = guidanceLines[i]
                let end = guidanceLines[i + 1]

                let distance = distanceFromPointToLine(
                    point: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                    lineStart: CLLocation(latitude: start.latitude, longitude: start.longitude),
                    lineEnd: CLLocation(latitude: end.latitude, longitude: end.longitude)
                )

                if abs(distance) < abs(closestDistance) {
                    closestDistance = distance
                    // Calculate heading of this guidance line
                    targetHeading = CustomOverlay.calculateHeading(from: start, to: end)
                }
            }

            TractorLiveActivityManager.shared.updateActivity(
                heading: targetHeading ?? 0, // Use guidance line heading
                speed: currentSpeed * 3.6,
                area: coveredArea / 4046.86,
                isTracking: isTracking,
                distanceFromLine: distanceFromLine,
                shouldTurnLeft: shouldTurnLeft
            )
        }
    }
}
extension ManagerLocation {
    /// Tổng thời gian session hiện tại (giây)
    func currentSessionDuration() -> TimeInterval {
        let session = trackingSessions.last ?? []
        guard let first = session.first?.timestamp, let last = session.last?.timestamp else { return 0 }
        return last.timeIntervalSince(first)
    }

    /// Elevation Gain (nếu TrackPoint có altitude)
    func currentSessionElevationGain() -> Double {
        let session = trackingSessions.last ?? []
        var gain: Double = 0
        var lastAlt: Double?
        for p in session {
            let alt = p.coordinate.latitude
            if let prev = lastAlt, alt > prev {
                gain += (alt - prev)
            }
            lastAlt = alt
        }
        return gain
    }
}
