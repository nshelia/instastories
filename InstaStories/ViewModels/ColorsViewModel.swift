//
//  ColorsViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 20.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

struct Color {
	let value: UIColor
	var isActive: Bool = false
}


final class ColorsViewModel {
	
	let colors: BehaviorRelay<[Color]> = BehaviorRelay(value: [])
		
	private var disposeBag = DisposeBag()
		
	
	static let collectionViewCellGutter: CGFloat = 10
	
	init() {
		
		let transformedColors = Constants.colors.enumerated().map { (index,item) in
				return Color(value: item, isActive: index == 0)
		}
		
		self.colors.accept(transformedColors)
		
	}
}
