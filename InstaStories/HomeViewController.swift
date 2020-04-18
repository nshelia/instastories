//
//  ViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 01.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import UIKit
import YogaKit
import Photos
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
	
	var addImagesButton: UIButton!
	
	let bag = DisposeBag()
	
	private let viewModel: HomeViewModel
	
	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("App crashed")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		
		viewModel.requestStatus().subscribe(
			onSuccess: { [weak self] authorized in
				if !authorized {
					DispatchQueue.main.async {
						self?.showMessage(title: "No access to Camera Roll", description: "You can grant access to Combinestagram from the Settings app")
					}
				}
			}
		).disposed(by: bag)
		
	}
	
	
	func setupView() {
		
		self.navigationItem.title = "InstaStoryEditor"
		
		view.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.size.width)
			layout.height = YGValue(self.view.bounds.size.height)
			layout.alignItems = .center
			layout.justifyContent = .center
		}
		
		let addImagesButton = UIButton()
		
		// MARK: Cocoa Bindings
		
		addImagesButton.rx.tap.bind {
			let viewController = PhotosViewController(viewModel: PhotosViewModel())
			self.navigationController?.pushViewController(viewController, animated: true)
		}.disposed(by: bag)
		
		let image = UIImage(named: "plus") as UIImage?
		
		addImagesButton.setImage(image, for: .normal)
		
		addImagesButton.backgroundColor = .clear
		addImagesButton.layer.cornerRadius = 5
		addImagesButton.layer.borderWidth = 1
		addImagesButton.layer.borderColor = UIColor.black.cgColor
		
		addImagesButton.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 150
			layout.height = 150
		}
		
		view.addSubview(addImagesButton)
		
		view.yoga.applyLayout(preservingOrigin: true)
		
	}
	
}


