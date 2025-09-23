//
//  RecordData.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 17/9/25.
//


import MapKit

struct RecordData {
    var region: MKCoordinateRegion
    var coordinates: [CLLocationCoordinate2D]
    var time: String
    var coverArea: String
    var avgSpeed: String
    var elevationGain: String
    
}

