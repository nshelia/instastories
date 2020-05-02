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
	typealias ClosestView = UIView & CanvasItemViewProtocol
	
	func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		let path = UIBezierPath()
		path.move(to: fromPoint)
		path.addLine(to: toPoint)
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = currentDrawingColor.cgColor
		shapeLayer.lineWidth = 10
		shapeLayer.cornerRadius = 5
		shapeLayer.lineCap = .round
		
		drawingPaper.layer.addSublayer(shapeLayer)
	}
	
	func gestureIntersetsWithTrash(gesture: UIGestureRecognizer) -> Bool {
		let location = gesture.location(in: drawingPaper)
		let touchFrameSquared = CGRect(center: location, size: CGSize(width: 50.0, height: 50.0))
		let trashViewFrame = CGRect(x: trashView.trashArea.frame.origin.x, y: trashView.frame.origin.y, width: trashView.frame.size.width, height: trashView.frame.size.height)
		
		return touchFrameSquared.intersects(trashViewFrame)
	}
	
	private func getClosetView(for gesture: UIGestureRecognizer) -> ClosestView? {
		if (gesture.state == .ended) {
			
			if gestureIntersetsWithTrash(gesture: gesture) {
				currentlyMoving.value?.removeFromSuperview()
			}
			
			gestureShadowView.transform = .identity
			gestureShadowView.removeFromSuperview()
			currentlyMoving.accept(nil)
			return nil
		}

		guard let gestureView = gesture.view else { return nil }
		if (gesture.state == .began) {

			var frame = CGRect.zero
			if gesture.numberOfTouches > 1 {
				let touchOne = gesture.location(ofTouch: 0, in: drawingPaper)
				let touchTwo = gesture.location(ofTouch: 1, in: drawingPaper)
				let topPoint = touchOne.y > touchTwo.y ? touchOne : touchTwo
				let bottomPoint = touchOne.y < touchTwo.y ? touchOne : touchTwo
				frame = CGRect.init(p1: bottomPoint, p2: topPoint)
			} else {
				let location = gesture.location(in: drawingPaper)
				frame = CGRect(center: location, size: CGSize(width: 50.0, height: 50.0))
			}
			gestureShadowView.frame = frame
			gestureView.addSubview(gestureShadowView)
			gestureView.bringSubviewToFront(gestureShadowView)
			
			for subview in gestureView.subviews {
				guard let view = subview as? UIView & CanvasItemViewProtocol else { continue }
				if view.minimumNumberOfTouches > gesture.numberOfTouches {
					continue
				}
				if view.intersectsWith(gestureShadowView) {
					self.initialCenter = view.center
					currentlyMoving.accept(view)
					// Means it a image view
					if view.minimumNumberOfTouches != 2 {
						drawingPaper.bringSubviewToFront(currentlyMoving.value!)
					}
				}
			}
		}
		
		if (gesture.state == .changed) {
		
			if gestureIntersetsWithTrash(gesture: gesture) {
				UIView.animate(withDuration: 0.3) { [weak self] in
					guard let self = self else { return }
					self.trashView.trashArea.transform = .init(scaleX: 0.6, y: 0.6)
				}
			} else {
				UIView.animate(withDuration: 0.3) { [weak self] in
					guard let self = self else { return }
					self.trashView.trashArea.transform = .identity
				}
			}
			
			return currentlyMoving.value
		}
		
		return nil
	}
	
	@objc func swiper(_ gestureRecognizer: TouchCaptureGesture) {
		
		if gestureRecognizer.state == .began {
			drawingScene(visible: false)
		}
		
		if gestureRecognizer.state == .ended {
			drawingScene(visible: true)
		}
		
		if (gestureRecognizer.samples.count > 1) {
			let firstPoint = gestureRecognizer.samples[gestureRecognizer.samples.count - 2].location
			let secondPoint = gestureRecognizer.samples.last!.location
			drawLine(from: firstPoint, to: secondPoint)
		}
	}
	
	
	@objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let closestView = getClosetView(for: gestureRecognizer) else {
			return
		}
		
		let translation = gestureRecognizer.translation(in: self.view)

		if gestureRecognizer.state != .cancelled {
			let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
			closestView.center = newCenter
		} else {
			closestView.center = initialCenter
		}
	
	}
	
	
	@objc func handleRotate(_ gestureRecognizer: UIRotationGestureRecognizer) {
		guard let closestView = getClosetView(for: gestureRecognizer) else {
			return
		}

		if gestureRecognizer.state != .cancelled {
			closestView.transform =  closestView.transform.rotated(by: gestureRecognizer.rotation)
		}

		gestureRecognizer.rotation = 0;
	}
	
	
	@objc func handleScale(_ gestureRecognizer: UIPinchGestureRecognizer) {
		guard let closestView = getClosetView(for: gestureRecognizer) else {
			return
		}

		if gestureRecognizer.state != .cancelled {
			closestView.transform = closestView.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
		}

		gestureRecognizer.scale = 1;
	}

}
