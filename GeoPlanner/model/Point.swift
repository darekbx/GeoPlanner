//
//  Point.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 03/11/2024.
//

import Foundation

struct Point: Codable, Hashable {
    var altitude: Double
    var latitude: Double
    var longitude: Double
    var speed: Double
    var timestamp: Date
    
    var speedInKmh: Double {
        return speed * 3.6
    }
}
