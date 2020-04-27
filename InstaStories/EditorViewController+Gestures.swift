//
//  EditorViewController+Gestures.swift
//  InstaStories
//
//  Created by Nika Shelia on 27.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

extension EditorViewController {
	func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		let path = UIBezierPath()
		path.move(to: fromPoint)
		path.addLine(to: toPoint)
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = currentDrawingColor.cgColor
		shapeLayer.lineWidth = 5
		
		drawingPaper.layer.addSublayer(shapeLayer)
	}
	
	@objc func swiper(_ gestureRecognizer: TouchCaptureGesture) {
		
		if gestureRecognizer.state == .began {
			completionView.isHidden = true
			colorsCollectionViewController.view.isHidden = true
		}
		
		if gestureRecognizer.state == .ended {
			completionView.isHidden = false
			colorsCollectionViewController.view.isHidden = false
		}
		
		if (gestureRecognizer.samples.count > 1) {
			let firstPoint = gestureRecognizer.samples[gestureRecognizer.samples.count - 2].location
			let secondPoint = gestureRecognizer.samples.last!.location
			drawLine(from: firstPoint, to: secondPoint)
		}
	}
	
	
	@objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let gestureView = gestureRecognizer.view else { return  }
		for subview in gestureView.subviews {
			guard let view = subview as? UIView & CanvasItemViewProtocol else { continue }
			if view.minimumNumberOfTouches > gestureRecognizer.numberOfTouches {
				continue
			}
			let translation = gestureRecognizer.translation(in: self.view)
			if gestureRecognizer.state == .began {
				self.initialCenter = view.center
			}
			if gestureRecognizer.state != .cancelled {
				let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
				view.center = newCenter
			} else {
				view.center = initialCenter
			}
		}
	}
	
	
	@objc func handleRotate(_ gestureRecognizer: UIRotationGestureRecognizer) {
		let view = gestureRecognizer.view
		let loc = gestureRecognizer.location(in: view)
		
		guard let subview = view?.hitTest(loc, with: nil) else {
			return
		}
		
		if gestureRecognizer.state == .began {
			currentlyMoving = subview
		}
		
		if gestureRecognizer.state != .cancelled {
			currentlyMoving.transform =  currentlyMoving.transform.rotated(by: gestureRecognizer.rotation)
		}
		
		gestureRecognizer.rotation = 0;
	}
	
	
	@objc func handleScale(_ gestureRecognizer: UIPinchGestureRecognizer) {
		let view = gestureRecognizer.view
		let loc = gestureRecognizer.location(in: view)
		
		guard let subview = view?.hitTest(loc, with: nil) else {
			return
		}
		
		if gestureRecognizer.state == .began {
			currentlyMoving = subview
		}
		
		if gestureRecognizer.state != .cancelled {
			currentlyMoving.transform = currentlyMoving.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
		}
		
		
		gestureRecognizer.scale = 1;
	}

}
