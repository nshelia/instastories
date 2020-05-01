//
//  SceneNavigatorViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 27.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SceneNavigatorViewModel {
	
	let closeButtonPress = PublishRelay<Void>()
	let brushButtonPress = PublishRelay<Void>()
	let textFieldButtonPress = PublishRelay<Void>()
	let stickersButtonPress = PublishRelay<Void>()

}
