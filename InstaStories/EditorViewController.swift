//
//  EditorViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 17.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YogaKit

class EditorViewController: UIViewController, UIGestureRecognizerDelegate {
	
	var initialCenter = CGPoint()
	
	let bag = DisposeBag()
	
	var initialImage: PhotoView
	
	var topSafeAreaHeight: CGFloat = 0
	var bottomSafeAreaHeight: CGFloat = 0
	
	private let viewModel: EditorViewModel!
	
	var imageView: UIImageView!
	
	let containerView: UIView =  {
		let containerView = UIView()
		
		containerView.configureLayout { (layout) in
			layout.isEnabled = true
			layout.paddingHorizontal = 0
			layout.justifyContent = .spaceBetween
			layout.flexDirection = .column
		}
				
		return containerView
	}()
	
	init(viewModel: EditorViewModel, initialImage: PhotoView) {
		self.viewModel = viewModel
		self.initialImage = initialImage
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("App crashed")
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.view.backgroundColor = .black
		
		self.navigationItem.title = "Photo Editor"
		self.navigationController?.navigationBar.isHidden = true
		
		containerView.yoga.width = YGValue(self.view.bounds.size.width)
		containerView.yoga.height =  YGValue(self.view.bounds.size.height)

		self.view.addSubview(containerView)
		if #available(iOS 11.0, *) {
			let window = UIApplication.shared.windows[0]
			let safeFrame = window.safeAreaLayoutGuide.layoutFrame
			topSafeAreaHeight = safeFrame.minY
			bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
		}
		setupView()
		bindViews()
		addGestures()
		
		viewModel.addItem(item: initialImage)
		viewModel.fetchOriginalImage(localIdentifier: initialImage.localIdentifier)
		containerView.yoga.applyLayout(preservingOrigin: true)

	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func setupView() {
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = true
		imageView.isMultipleTouchEnabled = true
		
		self.view.addSubview(imageView)
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
		])
		
		addHeaderView()
		addBottomView()
	}


	func bindViews() {
		viewModel.photoInView.asDriver(onErrorJustReturn: PhotoView.defaultImage())
			.map({ $0.image})
			.drive(imageView.rx.image).disposed(by: bag)
	}
	
	func addGestures() {
		let pinchGesture = UIPinchGestureRecognizer()
		pinchGesture.addTarget(self, action: #selector(handleScale))
		
		let rotationGesture = UIRotationGestureRecognizer()
		rotationGesture.addTarget(self, action: #selector(handleRotate))
		
		let panGesture = UIPanGestureRecognizer()
		panGesture.addTarget(self, action: #selector(handlePan))
		
		rotationGesture.delegate = self
		pinchGesture.delegate = self
		panGesture.delegate = self
		
		self.view.addGestureRecognizer(rotationGesture)
		self.view.addGestureRecognizer(pinchGesture)
		self.view.addGestureRecognizer(panGesture)
		
	}
	
	
	@objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		let translation = gestureRecognizer.translation(in: self.view)
		if gestureRecognizer.state == .began {
			self.initialCenter = imageView.center
		}
		if gestureRecognizer.state != .cancelled {
			let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
			imageView.center = newCenter
		} else {
			imageView.center = initialCenter
		}
	}
	
	
	@objc func handleRotate(_ gestureRecognizer: UIRotationGestureRecognizer) {
		imageView.transform =  imageView.transform.rotated(by: gestureRecognizer.rotation)
		gestureRecognizer.rotation = 0;
	}
	
	
	@objc func handleScale(_ gestureRecognizer: UIPinchGestureRecognizer) {
		imageView.transform = imageView.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
		gestureRecognizer.scale = 1;
	}
	
	func addHeaderView() {
		
		let wrapperView = createWrapperView()
		containerView.addSubview(wrapperView)
		let closeButton = createHeaderButton(imageIdentifier: "close")
		let drawButton = createHeaderButton(imageIdentifier: "brush")
		
		closeButton.rx.tap.bind {
			let transition: CATransition = CATransition()
			transition.duration =	0.3
			transition.type = CATransitionType.fade
			self.navigationController?.view.layer.add(transition, forKey: nil)

			self.navigationController?.popViewController(animated: false)
		}.disposed(by: bag)
		
		wrapperView.addSubview(closeButton)
		wrapperView.addSubview(drawButton)

		self.view.bringSubviewToFront(containerView)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		containerView.yoga.applyLayout(preservingOrigin: true)
	}
	
	func addBottomView() {
		let wrapperView = createWrapperView()
		
		wrapperView.yoga.paddingBottom = YGValue(bottomSafeAreaHeight)
		wrapperView.yoga.justifyContent = .flexEnd
		containerView.addSubview(wrapperView)
		let saveButton = createSaveButton()
		wrapperView.addSubview(saveButton)
	}
	
	
	func bindViewModel() {
		
	}
	
	func createSaveButton() -> UIButton {
		let buttonImage = UIImage(named: "save") as UIImage?
		let button = UIButton(type: .custom)
		button.contentMode = .scaleAspectFit
		button.setTitle("Save", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 20)
		button.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
		button.layer.cornerRadius = 10
		button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		button.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 120
		}
		
		button.setImage(buttonImage, for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
		return button
	}
	
	func createHeaderButton(imageIdentifier: String) -> UIButton {
		let buttonImage = UIImage(named: imageIdentifier) as UIImage?
		let button = UIButton(type: .custom)
		button.contentMode = .scaleAspectFill
		
		button.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = 40
			layout.height = 40
		}
		
		button.setImage(buttonImage, for: .normal)
		
		return button
		
	}
	
	func createWrapperView()  -> UIView{
		let wrapperView = UIView()
		
		wrapperView.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.size.width)
			layout.marginTop = YGValue(self.topSafeAreaHeight)
			layout.paddingHorizontal = 20
			layout.justifyContent = .spaceBetween
			layout.flexDirection = .row
		}
		
		return wrapperView

	}
	
}


