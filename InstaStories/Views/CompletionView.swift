//
//  CompletionView.swift
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

class CompletionView: UIView {
	
	let bag = DisposeBag()
	
	let viewModel: CompletionViewModel
	
	var doneButton: UIButton!
	
	func createDoneButton() -> UIButton {
		doneButton = UIButton(type: .custom)
		doneButton.setTitle("DONE", for: .normal)
		doneButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
		doneButton.configureLayout { (layout) in
			layout.isEnabled = true
		}

		doneButton.rx.tap.subscribe(onNext: { [weak self] in
			self?.viewModel.doneButtonPress.accept(())
		}).disposed(by: bag)
		
		return doneButton
	}

	
	init(viewModel: CompletionViewModel, frame: CGRect) {
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
			layout.top = YGValue(Constants.topSafeAreaHeight)
		}
		
		self.addSubview(createDoneButton())
		
		self.yoga.applyLayout(preservingOrigin: true)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
