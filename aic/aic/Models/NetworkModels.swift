//
//  PathModels.swift
//  aic
//
//  Created by Filippo Vanucci on 10/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class NodeModel : NSObject {
	let nid: Int
	let coordinate:CLLocationCoordinate2D
	var connectedSegmentNode: [SegmentModel: NodeModel] = [:]
	
	init(nid: Int, coordinate: CLLocationCoordinate2D) {
		self.nid = nid
		self.coordinate = coordinate
	}
}

class SegmentModel : NSObject {
	let nid: Int
	var nodes = Array<NodeModel>()
	
	init(nid: Int, nodes: Array<NodeModel>) {
		self.nid = nid
		self.nodes = nodes
	}
}

class NetworkModel {
	var nodes = Array<NodeModel>()
	var segments = Array<SegmentModel>()
	
	func loadData() {
		let networkJsonPath = Bundle.main.url(forResource: "network", withExtension: "json", subdirectory:Common.Map.mapsDirectory)
		do {
			let networkJsonData: Data = try Data(contentsOf: networkJsonPath!)
			let networkJson: JSON = JSON(data: networkJsonData)
			
			if networkJson["nodes"].exists() == true {
				for nodeJson: JSON in networkJson["nodes"].arrayValue {
					let nodeNid = nodeJson["nid"].intValue
					let nodeCoordinates = nodeJson["coordinates"].arrayValue
					
					let node = NodeModel(nid: nodeNid, coordinate: CLLocationCoordinate2D(latitude: nodeCoordinates[0].doubleValue, longitude: nodeCoordinates[1].doubleValue))
					nodes.append(node)
				}
			}
			
			if networkJson["segments"].exists() == true {
				for segmentJson: JSON in networkJson["segments"].arrayValue {
					let segmentNid = segmentJson["nid"].intValue
					let segmentNodeIds = segmentJson["nodes"].arrayValue
					
					var segmentNodes = Array<NodeModel>()
					segmentNodes.append(getNode(segmentNodeIds[0].intValue)!)
					segmentNodes.append(getNode(segmentNodeIds[1].intValue)!)
					let segment = SegmentModel(nid: segmentNid, nodes: segmentNodes)
					segments.append(segment)
				}
			}
		}
		catch let error as NSError {
			// Catch fires here, with an NSError being thrown from the JSONObjectWithData method
			print("Network JSON parsing error:\n \(error)")
		}
	}
	
	func getNode(_ nid: Int) -> NodeModel? {
		for node: NodeModel in nodes {
			if node.nid == nid {
				return node
			}
		}
		return nil
	}
}
