//
//  PathModels.swift
//  aic
//
//  Created by Filippo Vanucci on 10/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import SwiftyJSON

class NodeModel : NSObject {
	let nid: Int
	let coordinate:CLLocationCoordinate2D
	var connectedSegmentNode: [SegmentModel: NodeModel] = [:]
	
	var visited: Bool = false
	var connections: [Connection] = []
	
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

class Connection {
	public let to: NodeModel
	public let distance: Double
	
	public init(to node: NodeModel, distance: Double) {
		assert(distance >= 0, "weight has to be equal or greater than zero")
		self.to = node
		self.distance = distance
	}
}

class PathModel {
	var destination: NodeModel!
	var total: Double!
	var previous: PathModel!
	
	public let cumulativeDistance: Double
	public let node: NodeModel
	public let previousPath: PathModel?
	
	init(to node: NodeModel, via connection: Connection? = nil, previousPath path: PathModel? = nil) {
		if let previousPath = path, let viaConnection = connection {
			self.cumulativeDistance = viaConnection.distance + previousPath.cumulativeDistance
		} else {
			self.cumulativeDistance = 0
		}
		
		self.node = node
		self.previousPath = path
	}
}

extension PathModel {
	var array: [NodeModel] {
		var array: [NodeModel] = [self.node]
		
		var iterativePath = self
		while let path = iterativePath.previousPath {
			array.append(path.node)
			
			iterativePath = path
		}
		
		return array
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
					
					let node = NodeModel(nid: nodeNid, coordinate: CLLocationCoordinate2D(latitude: nodeCoordinates[1].doubleValue, longitude: nodeCoordinates[0].doubleValue))
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
				
				for segment: SegmentModel in segments {
					segment.nodes[0].connectedSegmentNode[segment] = segment.nodes[1]
					segment.nodes[1].connectedSegmentNode[segment] = segment.nodes[0]
					let distance = getDistance(fromNode: segment.nodes[0], toNode: segment.nodes[1])
					segment.nodes[0].connections.append(Connection(to: segment.nodes[1], distance: distance))
					segment.nodes[1].connections.append(Connection(to: segment.nodes[0], distance: distance))
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
	
	func getDistance(fromNode: NodeModel, toNode: NodeModel) -> CLLocationDistance {
		let fromMapPoint = MKMapPointForCoordinate(fromNode.coordinate)
		let toMapPoint = MKMapPointForCoordinate(toNode.coordinate)
		return MKMetersBetweenMapPoints(fromMapPoint, toMapPoint)
	}
	
	// https://medium.com/swiftly-swift/dijkstras-algorithm-in-swift-15dce3ed0e22
	func shortestPath(source: NodeModel, destination: NodeModel) -> PathModel? {
		for node: NodeModel in nodes {
			node.visited = false
		}
		
		var frontier: [PathModel] = [] {
			didSet { frontier.sort { return $0.cumulativeDistance < $1.cumulativeDistance } } // the frontier has to be always ordered
		}
		
		frontier.append(PathModel(to: source)) // the frontier is made by a path that starts nowhere and ends in the source
		
		while !frontier.isEmpty {
			let cheapestPathInFrontier = frontier.removeFirst() // getting the cheapest path available
			guard !cheapestPathInFrontier.node.visited else { continue } // making sure we haven't visited the node already
			
			if cheapestPathInFrontier.node === destination {
				return cheapestPathInFrontier // found the cheapest path 😎
			}
			
			cheapestPathInFrontier.node.visited = true
			
			for connection in cheapestPathInFrontier.node.connections where !connection.to.visited { // adding new paths to our frontier
				frontier.append(PathModel(to: connection.to, via: connection, previousPath: cheapestPathInFrontier))
			}
		} // end while
		return nil // we didn't find a path 😣
	}
}
