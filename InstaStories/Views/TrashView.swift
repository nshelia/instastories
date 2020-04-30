//
//  TrashView.swift
//  InstaStories
//
//  Created by Nika Shelia on 30.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit
import YogaKit

class TrashView: UIView {
		
	var trashArea: UIButton!
	
	func createTrashButton() -> UIButton {
		let buttonImage = UIImage(named: "trash") as UIImage?
		trashArea = UIButton(type: .custom)
		trashArea.isUserInteractionEnabled = true
		trashArea.contentMode = .scaleAspectFill
		
		trashArea.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 40
			layout.height = 40
		}
		
		trashArea.setImage(buttonImage, for: .normal)
		
		return trashArea
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.configureLayout { layout in
			layout.isEnabled = true
			layout.position = .absolute
			layout.width = YGValue(UIScreen.main.bounds.size.width)
			layout.paddingHorizontal = 20
			layout.flexDirection = .row
			layout.height = 60
			layout.justifyContent = .center
			layout.bottom = YGValue(Constants.bottomSafeAreaHeight)
		}
		
		self.addSubview(createTrashButton())
		
		self.yoga.applyLayout(preservingOrigin: true)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
