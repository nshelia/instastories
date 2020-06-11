//
//  StickersViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 01.05.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class StickersViewModel {
	
	let stickers: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
	
	private var disposeBag = DisposeBag()
	
	public var imageSelected = BehaviorRelay<UIImage?>(value: nil)
	
	init() {
		let fileManager = FileManager.default
		let imagePath = Bundle.main.resourcePath! + "/Stickers/"
//		let imageNames: [String] = try! fileManager.contentsOfDirectory(atPath: imagePath)
		
		stickers.accept([])
	}

}
