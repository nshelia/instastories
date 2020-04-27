//
//  CanvasItem.swift
//  InstaStories
//
//  Created by Nika Shelia on 26.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

protocol CanvasItemViewProtocol {
	var minimumNumberOfTouches: Int { get }
}

class CanvasItem: UIView, CanvasItemViewProtocol {
	let minimumNumberOfTouches: Int
	
	init(minimumNumberOfTouches: Int, frame: CGRect) {
		self.minimumNumberOfTouches = minimumNumberOfTouches
		super.init(frame: frame)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
