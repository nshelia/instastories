//
//  PhotoView.swift
//  InstaStories
//
//  Created by Nika Shelia on 18.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

struct PhotoView {
	let localIdentifier: String
	let image: UIImage
	let aspectRatio: Double
	let pixelWidth: Int
	let pixelHeight: Int
	
	static func defaultImage() -> PhotoView {
		return PhotoView(localIdentifier: "", image: UIImage(), aspectRatio: 1.0, pixelWidth: 100, pixelHeight: 100)
	}
}
