//
//  TouchStateCaptureGesture.swift
//  InstaStories
//
//  Created by Nika Shelia on 23.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TouchStateCaptureGesture: UIGestureRecognizer, NSCoding {
	var touchState = BehaviorRelay<UIGestureRecognizer.State>(value: .possible)
	
	required init?(coder aDecoder: NSCoder) {
		super.init(target: nil, action: nil)
	}
	
	func encode(with aCoder: NSCoder) { }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		if touches.count != 1 {
			self.state = .failed
		}
		
		touchState.accept(.began)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		touchState.accept(.changed)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		touchState.accept(.ended)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		touchState.accept(.cancelled)
	}
	
}
