//
//  ViewGestureTransformer.swift
//  InstaStories
//
//  Created by Nika Shelia on 19.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit


class ViewGestureTransformer: UIView, UIGestureRecognizerDelegate {
	
	var initialCenter = CGPoint()

	override init(image: UIImage!) {
		super.init(image: image)
		self.initialSetup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
}
