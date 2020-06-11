//
//  SaveView.swift
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

class SaveView: UIView {
	
	let viewModel: SaveViewModel

	let bag = DisposeBag()
	
	var saveButton: UIButton!
	
	func createSaveButton() -> UIButton {
		let buttonImage = UIImage(named: "save") as UIImage?
		saveButton = UIButton(type: .custom)
		saveButton.contentMode = .scaleAspectFit
		saveButton.setTitle("Save", for: .normal)
		saveButton.titleLabel?.font = .systemFont(ofSize: 20)
		saveButton.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
		saveButton.layer.cornerRadius = 10
		saveButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		saveButton.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 120
		}
		
		saveButton.setImage(buttonImage, for: .normal)
		saveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
		return saveButton
	}
	
	init(viewModel: SaveViewModel, frame: CGRect) {
		self.viewModel = viewModel

		super.init(frame: frame)
		
		self.configureLayout { layout in
			layout.isEnabled = true
			layout.position = .absolute
			layout.width = YGValue(UIScreen.main.bounds.size.width)
			layout.paddingHorizontal = 20
			layout.flexDirection = .row
			layout.height = 60
			layout.justifyContent = .flexEnd
			layout.bottom = YGValue(Constants.bottomSafeAreaHeight)
		}
				

		
		self.addSubview(createSaveButton())
		
		saveButton.rx.tap.subscribe(onNext: {
			self.viewModel.saveButtonPress.accept(())
		}).disposed(by: bag)
		
		self.yoga.applyLayout(preservingOrigin: true)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
