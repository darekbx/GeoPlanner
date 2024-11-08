//
//  WindTurbinesProvider.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 08/11/2024.
//

import Foundation

class WindTurbinesProvider: ObservableObject {
    
    @Published var turbines: [WindTurbine] = []
    
    @MainActor
    func fetchTurbines() {
        let url = URL(string: "https://overpass-api.de/api/interpreter?data=%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0Anwr%5B%22generator%3Amethod%22%3D%22wind_turbine%22%5D%2851.51219196266224%2C18.468017578125004%2C52.902305628635254%2C23.9007568359375%29%3B%0Aout%20geom%3B")
        guard let url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        
        URLSession(configuration: sessionConfig).dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fetch error", error)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            do {
                let wrapper = try JSONDecoder().decode(OverpassWrapper.self, from: data)
                DispatchQueue.main.async {
                    self.turbines = wrapper.elements.filter { $0.hasLocation() }
                }
            } catch let jsonError {
                print("Failed to parse json", jsonError)
            }
        }.resume()
    }
}
