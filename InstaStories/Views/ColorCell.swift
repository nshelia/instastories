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

class ColorCell: UICollectionViewCell {
	
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func configure(color: CGColor) {
		self.contentView.backgroundColor = UIColor(cgColor: color)
		setupView()
	}
	
	func setupView() {
	
		self.layer.masksToBounds = true
		self.layer.cornerRadius = 25

	}
	
}


