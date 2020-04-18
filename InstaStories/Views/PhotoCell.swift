//
//  PhotoCell.swift
//  InstaStories
//
//  Created by Nika Shelia on 16.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation

import UIKit
import YogaKit

class PhotoCell: UICollectionViewCell {
	
	private var viewModel: PhotoView!

  override init(frame: CGRect) {
    
    super.init(frame: .zero)
    
	}

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
	
	func configure(viewModel: PhotoView) -> Void {
		self.viewModel = viewModel
		setupView()

	}
	
	func setupView() {
		
		self.contentView.backgroundColor = .red

		let mainImage = UIImageView()
		
		mainImage.image = viewModel.image
		mainImage.translatesAutoresizingMaskIntoConstraints  = false
		mainImage.contentMode = .scaleAspectFill
		
		self.contentView.addSubview(mainImage)
		
		NSLayoutConstraint.activate([
			mainImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			mainImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			mainImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
			mainImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor)
		])
    
		mainImage.tag = 100
		
		self.layer.masksToBounds = true
		self.layer.borderWidth = 1
		self.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		
	}
	
}


