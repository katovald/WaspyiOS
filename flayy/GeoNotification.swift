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
import GoogleMaps

struct Geokey{
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType = "eventType"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On exit"
}

class GeoNotification: GMSMarker, NSCoding{
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    @IBOutlet var titulo: String?{
        didSet{
            self.title = titulo
        }
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
    
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDouble(forKey: Geokey.latitude)
        let longitude = decoder.decodeDouble(forKey: Geokey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: Geokey.radius)
        identifier = decoder.decodeObject(forKey: Geokey.identifier) as! String
        note = decoder.decodeObject(forKey: Geokey.note) as! String
        eventType = EventType(rawValue: decoder.decodeObject(forKey: Geokey.eventType) as! String)!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: Geokey.latitude)
        coder.encode(coordinate.longitude, forKey: Geokey.longitude)
        coder.encode(radius, forKey: Geokey.radius)
        coder.encode(identifier, forKey: Geokey.identifier)
        coder.encode(note, forKey: Geokey.note)
        coder.encode(eventType.rawValue, forKey: Geokey.eventType)
    }
    
}
