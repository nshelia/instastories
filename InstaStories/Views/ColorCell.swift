//
//  ColorCell.swift
//  InstaStories
//
//  Created by Nika Shelia on 16.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation

import UIKit
import YogaKit
import RxCocoa
import RxSwift

class ColorCell: UICollectionViewCell {
	
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func configure(color: Color) {
		self.contentView.backgroundColor = color.value
		setupView()
		if color.isActive {
			makeActive()
		} else {
			self.layer.borderWidth = 1
		}
	}
	
	func animateBorder(from: CGFloat, to: CGFloat) {
		let borderWidth: CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
		borderWidth.fromValue = from
		borderWidth.toValue = to
		borderWidth.duration = 0.3
		self.layer.borderWidth = to
		self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		self.layer.add(borderWidth, forKey: "Width")
	}
	
	func makeActive() {
		animateBorder(from: 1, to: 3)
	}

	func setupView() {
	
		self.layer.masksToBounds = true
		self.layer.cornerRadius = Constants.collectionViewCellWidth / 2
		self.layer.borderWidth = 1
		self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

	}
	
}
