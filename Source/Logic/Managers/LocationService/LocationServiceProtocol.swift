//
//  LocationServiceProtocol.swift
//  MyMobileED
//
//  Created by Admin on 2/10/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationServiceProtocol: class {
    
    func currentLocation() -> CLLocationCoordinate2D?
    func currentLocationDescription() -> String?
}
