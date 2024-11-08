//
//  FirestoreWrapper.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 03/11/2024.
//

import Foundation

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class FirestoreWrapper: ObservableObject {
    
    @Published var tracks: [Track] = []
    
    private let displayMockData = false
    
    func fetchTracks() {

        if displayMockData {
            for _ in 0...20 {
                tracks.append(Track(id: "", distance: 12121, startTimestamp: Date.now, time: "10h 2m", points: []))
            }
            return
        }
        
        authenticate {
            let db = Firestore.firestore()
            let docRef = db
                .collection("track")
                .whereField("points", isNotEqualTo: "[]")
                .order(by: "start_timestamp", descending: true)
                //.limit(to: 120)
            docRef.getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print("Fetch error: \(error)")
                    return
                }
                self?.tracks = snapshot?.documents.compactMap { document in
                    let t = Track(from: document)
                    return t
                } ?? []
            }
        }
    }
    
    private func authenticate(_ authenticated: @escaping () -> Void) {
        let email = ProcessInfo.processInfo.environment["FIREBASE_EMAIL"]
        let password = ProcessInfo.processInfo.environment["FIREBASE_PASSWORD"]
        if let email = email, let password = password {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if result?.user != nil {
                    authenticated()
                } else if let error = error {
                    print("Authentication failed '\(error)'!")
                }
            }
        }
    }
}
