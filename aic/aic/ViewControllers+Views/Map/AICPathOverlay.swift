//
//  AICPathOverlay.swift
//  aic
//
//  Created by Philip Bernstein on 11/2/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import MapKit

class AICPathOverlay: MKPolygon {
    let representedIndex:Int!
    
    init(representedIndex:Int = 0) {
        self.representedIndex = representedIndex
    }
}
