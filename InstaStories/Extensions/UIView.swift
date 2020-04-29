//
//  UIView.swift
//  InstaStories
//
//  Created by Nika Shelia on 28.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

// Conform the `Polygon` protocol to specify the vertices of the polygon.
protocol Polygon {
	var vertices: [CGPoint] { get }
}
// UIView conforms the protocol `Polygon` to specified the vertices of the rectangle.
extension UIView: Polygon {
	var vertices: [CGPoint] {
		var point: CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
		point.x = -point.x
		point.y = -point.y
		var vertexA = point.applying(transform)
		vertexA.x += center.x
		vertexA.y += center.y
		point.x = -point.x;
		var vertexB = point.applying(transform)
		vertexB.x += center.x
		vertexB.y += center.y
		point.y = -point.y;
		var vertexC = point.applying(transform)
		vertexC.x += center.x
		vertexC.y += center.y
		point.x = -point.x;
		var vertexD = point.applying(transform)
		vertexD.x += center.x
		vertexD.y += center.y
		return [vertexA, vertexB, vertexC, vertexD]
	}
	/// Returns whether two views intersect.
	///
	/// - Parameter view2: The view to test the intersaction with this view.
	/// - Returns: `true` if the specified views intersect, otherwise `false`
	
	func intersectsWith(_ view2: UIView) -> Bool {
		let polygonA = self
		let polygonB = view2
		return UIView.intersects(polygonA: polygonA, polygonB: polygonB)
	}
	private static func intersects(polygonA: Polygon, polygonB: Polygon) -> Bool {
		for polygon in [polygonA, polygonB] {
			for index in 0..<polygon.vertices.count {
				let nextIndex = (index + 1) % polygon.vertices.count
				let point1 = polygon.vertices[index]
				let point2 = polygon.vertices[nextIndex]
				let normal = CGPoint(x: -(point2.y - point1.y), y: point2.x - point1.x)
				let (minProjectionA, maxProjectionA) = projectionOf(polygonA, with: normal)
				let (minProjectionB, maxProjectionB) = projectionOf(polygonB, with: normal)
				if maxProjectionA < minProjectionB || maxProjectionB < minProjectionA {
					return false
				}
			}
		}
		return true
	}
	private static func projectionOf(_ polygon: Polygon, with normal: CGPoint) -> (minP: CGFloat, maxP: CGFloat) {
		var minProjection: CGFloat = .infinity
		var maxProjection: CGFloat = -.infinity
		for point in polygon.vertices {
			let projection: CGFloat = point.x * normal.x + point.y * normal.y
			if projection > maxProjection {
				maxProjection = projection
			}
			if projection < minProjection {
				minProjection = projection
			}
		}
		return (minProjection, maxProjection)
	}
}
