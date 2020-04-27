//
//  SceneNavigatorView.swift
//  InstaStories
//
//  Created by Nika Shelia on 27.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit
import YogaKit
import RxSwift
import RxCocoa

class SceneNavigatorView: UIView {
	
	let viewModel: SceneNavigatorViewModel
	
	let bag = DisposeBag()
	
	var closeButton: UIButton!
	var drawButton: UIButton!
	var brushButton: UIButton!
	var textFieldButton: UIButton!
	
	func createCloseButton() -> UIButton {
		closeButton = createHeaderButton(imageIdentifier: "close")
		
		closeButton.rx.tap.subscribe(onNext: {
			self.viewModel.closeButtonPress.accept(())
		}).disposed(by: bag)
		
		return closeButton
	}
	
	func createDrawButton(imageIdentifier: String) -> UIButton {
		drawButton = createHeaderButton(imageIdentifier: imageIdentifier)
		
		return drawButton
	}
	
	func createDoneButton() -> UIButton {
		let doneButton = UIButton(type: .custom)
		doneButton.setTitle("DONE", for: .normal)
		doneButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
		doneButton.configureLayout { (layout) in
			layout.isEnabled = true
		}
		
		return doneButton
	}
	
	func createHeaderButton(imageIdentifier: String) -> UIButton {
		let buttonImage = UIImage(named: imageIdentifier) as UIImage?
		let button = UIButton(type: .custom)
		button.isUserInteractionEnabled = true
		button.contentMode = .scaleAspectFill
		
		button.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 40
			layout.height = 40
		}
		
		button.setImage(buttonImage, for: .normal)
		
		return button
		
	}
	
	 init(viewModel: SceneNavigatorViewModel, frame: CGRect) {
		self.viewModel = viewModel
		super.init(frame: frame)
		
		self.configureLayout { layout in
			layout.isEnabled = true
			layout.position = .absolute
			layout.display = .flex
			layout.width = YGValue(UIScreen.main.bounds.size.width)
			layout.paddingHorizontal = 20
			layout.flexDirection = .row
			layout.minHeight = 45
			layout.alignItems = .center
			layout.justifyContent = .spaceBetween
			layout.top = YGValue(Constants.topSafeAreaHeight)
		}

		let drawingActionsView = UIView()

		drawingActionsView.configureLayout { layout in
			layout.isEnabled = true
			layout.alignItems = .center
			layout.flexDirection = .row
			layout.justifyContent = .center
		}
		self.addSubview(createCloseButton())

		self.addSubview(drawingActionsView)

		brushButton = createDrawButton(imageIdentifier: "brush")
		
		brushButton.rx.tap.subscribe(onNext: {
			self.viewModel.brushButtonPress.accept(())
		}).disposed(by: bag)
		
		textFieldButton = createDrawButton(imageIdentifier: "textField")
		
		textFieldButton.rx.tap.subscribe(onNext: {
			self.viewModel.textFieldButtonPress.accept(())
		}).disposed(by: bag)
		
		drawingActionsView.addSubview(brushButton)
		drawingActionsView.addSubview(textFieldButton)

		self.yoga.applyLayout(preservingOrigin: true)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
