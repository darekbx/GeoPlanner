//
//  GpxCreator.swift
//  GeoPlanner
//
//  Created by Dariusz Baranczuk on 11/11/2024.
//

import Foundation
import MapKit
import UniformTypeIdentifiers

class GpxCreator {
    
    func exportToGpx(points: [CLLocationCoordinate2D]) {
        let root = XMLElement(name: "gpx")
        
        let metadata = XMLElement(name: "metadata")
        let name = XMLElement(name: "name", stringValue: "GPX Track")
        metadata.addChild(name)
        
        root.addChild(metadata)
        
        let trk = XMLElement(name: "trk")
        let trkseg = XMLElement(name: "trkseg")
        
        points.forEach { point in
            let trkpt = XMLElement(name: "trkpt")
            trkpt.addAttribute(XMLNode.attribute(withName: "lat", stringValue: "\(point.latitude)") as! XMLNode)
            trkpt.addAttribute(XMLNode.attribute(withName: "lon", stringValue: "\(point.longitude)") as! XMLNode)
            trkseg.addChild(trkpt)
        }
        
        trk.addChild(trkseg)
        root.addChild(trk)
        
        let xmlDoc = XMLDocument(rootElement: root)
        xmlDoc.version = "1.0"
        xmlDoc.characterEncoding = "UTF-8"
        
        let url = askForSaveLocation()
        if let url = url {
            do {
                try xmlDoc.xmlData(options: .nodePrettyPrint).write(to: url)
                print("XML saved to file")
            } catch {
                print("Failed to save XML: \(error)")
            }
        }
    }
    
    func askForSaveLocation() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "GPX save location"
        savePanel.prompt = "Save"
        savePanel.allowedContentTypes = [UTType.xml]
        
        let result = savePanel.runModal()
        if result == .OK {
            return savePanel.url
        } else {
            return nil
        }
    }
}
