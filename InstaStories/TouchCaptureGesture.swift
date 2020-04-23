//
//  TouchCaptureGesture.swift
//  InstaStories
//
//  Created by Nika Shelia on 23.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

struct StrokeSample {
	let location: CGPoint
	
	init(location: CGPoint) {
		self.location = location
	}
}

class TouchCaptureGesture: UIGestureRecognizer, NSCoding {
	var trackedTouch: UITouch? = nil
	var samples = [StrokeSample]()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(target: nil, action: nil)
		self.samples = [StrokeSample]()
	}
	
	func encode(with aCoder: NSCoder) { }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		if touches.count != 1 {
			self.state = .failed
		}
		
		if self.trackedTouch == nil {
			if let firstTouch = touches.first {
				self.trackedTouch = firstTouch
				self.addSample(for: firstTouch)
				state = .began
			}
		} else {
			for touch in touches {
				if touch != self.trackedTouch {
					self.ignore(touch, for: event)
				}
			}
		}
	}
	
	func addSample(for touch: UITouch) {
		let newSample = StrokeSample(location: touch.location(in: self.view))
		self.samples.append(newSample)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.addSample(for: touches.first!)
		
		state = .changed
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.addSample(for: touches.first!)
		state = .ended
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.samples.removeAll()
		state = .cancelled
	}
	
	override func reset() {
		self.samples.removeAll()
		self.trackedTouch = nil
	}
}
