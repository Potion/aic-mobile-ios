//
//  AICPathOverlayRenderer.swift
//  aic
//
//  Created by Philip Bernstein on 11/2/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import MapKit

class AICPathOverlayRenderer: MKPolygonRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
