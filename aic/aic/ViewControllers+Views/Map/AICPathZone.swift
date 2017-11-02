//
//  AICPathZone.swift
//  aic
//
//  Created by Philip Bernstein on 11/2/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import MapKit
struct AICPathZone {
    let coordinates:[CLLocationCoordinate2D]!
    let neighbors:[AICPathZone]!
    let index:Int!
    let centerCoordinate:CLLocationCoordinate2D!
}
