//
//  WindTurbine.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 08/11/2024.
//

import Foundation
import MapKit

struct OverpassWrapper: Codable {
    var elements: [WindTurbine]
}

struct WindTurbine: Codable, Hashable {
    var id: Int
    var type: String
    var tags: [String: String]
    var lat: Double? = nil
    var lon: Double? = nil
    
    func hasLocation() -> Bool {
        return self.lat != nil && self.lon != nil
    }
    
    func description() -> String {
        var height = tags["height"]
        if height != nil {
            height = "Height: \(height!)m"
        }
        var hubHeight = tags["height:hub"]
        if hubHeight != nil {
            hubHeight = "Height: \(hubHeight!)m"
        }
        return tags["model"] ?? height ?? hubHeight ?? ""
    }
}
