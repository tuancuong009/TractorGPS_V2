//
//  CoordinateHelper.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 17/9/25.
//
import SwiftUI
import MapKit

struct CoordinateHelper {
    static func encode(_ coords: [CLLocationCoordinate2D]) -> Data? {
        try? JSONEncoder().encode(coords.map { ["lat": $0.latitude, "lon": $0.longitude] })
    }
    
    static func decode(_ data: Data) -> [CLLocationCoordinate2D] {
        guard let arr = try? JSONDecoder().decode([[String: Double]].self, from: data) else {
            return []
        }
        return arr.compactMap { dict in
            if let lat = dict["lat"], let lon = dict["lon"] {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        }
    }
}
