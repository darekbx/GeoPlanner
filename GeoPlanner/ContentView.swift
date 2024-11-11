//
//  ContentView.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 29/10/2024.
//

import SwiftUI
import MapKit

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct ContentView: View {
    
    @StateObject private var firestoreWrapper = FirestoreWrapper()
    @StateObject private var windTurbinesProvider = WindTurbinesProvider()
    
    @State private var userLine: [CLLocationCoordinate2D] = []
    @State private var userDistance = 0.0
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        HStack {
            List(firestoreWrapper.tracks, id: \.self) { track in
                HStack {
                    Text("     \(dateFormatter.string(from: track.startTimestamp))")
                        .frame(maxWidth: 140)
                    Text(String(format: "%.2fkm", track.distance / 1000))
                        .frame(maxWidth: 60, alignment: .trailing)
                    Text(track.time)
                        .frame(maxWidth: 60, alignment: .trailing)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: 0))
            }
            .listStyle(PlainListStyle())
            .padding(.bottom, 8)
            .padding(.top, 8)
            .scrollContentBackground(.hidden)
            .background(Color(.darkGray))
            .frame(maxWidth: 230)
            .cornerRadius(10)
            
            VStack {
                MapReader { reader in
                    Map() {
                        TrackPolylinesView(firestoreWrapper: firestoreWrapper)
                        WindTurbinesView(windTurbinesProvider: windTurbinesProvider)
                        UserLineView(userLine: userLine)
                    }
                    .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                    .onTapGesture { screenCoord in
                        if let pinLocation = reader.convert(screenCoord, from: .local) {
                            userLine.append(pinLocation)
                            userDistance = totalDistance()
                        }
                    }
                }
                if userDistance > 0.0 {
                    UserLineToolbar()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.darkGray))
            .cornerRadius(10)
        }
        .padding(5)
        .task {
            firestoreWrapper.fetchTracks()
            windTurbinesProvider.fetchTurbines()
        }
    }
    
    fileprivate func UserLineToolbar() -> some View {
        HStack {
            Text(String(format: "%.2fkm", userDistance / 1000))
            Button(
                action: {
                    userLine.removeLast()
                    userDistance = totalDistance()
                },
                label: {
                    Text("Undo")
                }
            )
            Button(
                action: {
                    userLine.removeAll()
                    userDistance = 0.0
                },
                label: {
                    Text("Delete all")
                }
            )
            Button(
                action: {
                    GpxCreator().exportToGpx(points: userLine)
                },
                label: {
                    Text("Export to GPX")
                }
            )
        }
    }
    
    private func totalDistance() -> Double {
        var distance = 0.0
        
        for i in 0..<userLine.count - 1 {
            let start = CLLocation(latitude: userLine[i].latitude, longitude: userLine[i].longitude)
            let end = CLLocation(latitude: userLine[i + 1].latitude, longitude: userLine[i + 1].longitude)
            distance += end.distance(from: start)
        }
        
        return distance
    }
}

struct TrackPolylinesView: MapContent {

    @ObservedObject var firestoreWrapper: FirestoreWrapper
    
    var body: some MapContent {
        ForEach(firestoreWrapper.tracks, id: \.self) { track in
            let walkingRoute: [CLLocationCoordinate2D] = track.points.compactMap {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            MapPolyline(coordinates: walkingRoute)
                .stroke(.red, lineWidth: 1)
        }
    }
}

struct UserLineView: MapContent {
    
    var userLine: [CLLocationCoordinate2D] = []
    
    var body: some MapContent {
        MapPolyline(coordinates: userLine)
            .stroke(.green, lineWidth: 2)
        ForEach(userLine, id: \.self) { point in
            MapCircle(center: point, radius: 10)
                .foregroundStyle(.white)
        }
    }
}

struct WindTurbinesView: MapContent {
    
    @ObservedObject var windTurbinesProvider: WindTurbinesProvider
    
    var body: some MapContent {
        ForEach(windTurbinesProvider.turbines, id: \.self) { turbine in
        
            MapCircle(center: CLLocationCoordinate2D(latitude: turbine.lat!, longitude: turbine.lon!), radius: 200)
                .foregroundStyle(.yellow)
        
            //Marker(turbine.description(), systemImage: "fanblades", coordinate: CLLocationCoordinate2D(latitude: turbine.lat!, longitude: turbine.lon!))
            //    .tint(.gray.opacity(0))
        }
    }
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

#Preview {
    ContentView()
        .frame(width: 700, height: 400)
}
