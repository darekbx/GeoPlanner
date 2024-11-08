//
//  Track.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 03/11/2024.
//

import Foundation
import FirebaseFirestore

struct Track: Identifiable, Equatable, Hashable {
    var id: String
    var distance: Double
    var startTimestamp: Date
    var time: String
    var points: [Point]
    
    init(id: String, distance: Double, startTimestamp: Date, time: String, points: [Point]) {
        self.id = id
        self.distance = distance
        self.startTimestamp = startTimestamp
        self.time = time
        self.points = points
    }
    
    init?(from document: DocumentSnapshot) {
        guard let data = document.data(),
              let distance = data["distance"] as? Double,
              let startTimestamp = data["start_timestamp"] as? Int64,
              let endTimestamp = data["end_timestamp"] as? Int64
        else {
            return nil
        }
        
        self.points = []
        
        if let pointsData = data["points"] as? String {
            do {
                self.points = try JSONDecoder().decode([Point].self, from: pointsData.data(using: .utf8)!)
            } catch { }
        }
        
        self.id = document.documentID
        self.distance = distance
        self.startTimestamp = Date(timeIntervalSince1970: TimeInterval(startTimestamp / 1000))
        
        let timeInterval = TimeInterval(endTimestamp / 1000 - startTimestamp / 1000)
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        let formattedDiff = String(format: "%02dh %02dm", hours, minutes)
        self.time = formattedDiff
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id &&
        lhs.distance == rhs.distance &&
        lhs.startTimestamp == rhs.startTimestamp
    }
}
