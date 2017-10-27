//
//  GeoNotification.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct Geokey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType = "eventTYpe"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

class Geotification: NSObject, NSCoding, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(coordinate.latitude, forKey: Geokey.latitude)
        aCoder.encode(coordinate.longitude, forKey: Geokey.longitude)
        aCoder.encode(radius, forKey: Geokey.radius)
        aCoder.encode(identifier, forKey: Geokey.identifier)
        aCoder.encode(note, forKey: Geokey.note)
        aCoder.encode(eventType.rawValue, forKey: Geokey.eventType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: Geokey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: Geokey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = aDecoder.decodeDouble(forKey: Geokey.radius)
        identifier = aDecoder.decodeObject(forKey: Geokey.identifier) as! String
        note = aDecoder.decodeObject(forKey: Geokey.note) as! String
        eventType = EventType(rawValue: aDecoder.decodeObject(forKey: Geokey.eventType) as! String)!
    }
    

}
