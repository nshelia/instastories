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
	
	var closeButton: UIButton!
	var drawButton: UIButton!
	var saveButton: UIButton!
	var bottomView: UIView!
	
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

	}
	
	func setupView() {
		setupImageView()
		addHeaderView()
		addBottomView()
		containerView.yoga.applyLayout(preservingOrigin: true)

	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func setupImageView() {
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
	}


	func bindViews() {
		viewModel.mainViewIsHidden.bind(to: closeButton.rx.isHidden).disposed(by: bag)
		viewModel.mainViewIsHidden.bind(to: drawButton.rx.isHidden).disposed(by: bag)
		
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
		wrapperView.yoga.top = YGValue(self.topSafeAreaHeight)
		containerView.addSubview(wrapperView)
		closeButton = createHeaderButton(imageIdentifier: "close")
		drawButton = createHeaderButton(imageIdentifier: "brush")
		
		drawButton.rx.tap.bind { [weak self ] _ in
			guard let self = self else { return }
			self.viewModel.mainViewIsHidden.accept(true)
			self.addColorsCollectionView()

		}.disposed(by: bag)
		
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
	
	func addColorsCollectionView() {
		saveButton.removeFromSuperview()
		bottomView.yoga.justifyContent = .center
		let collectionView = ColorsCollectionView()
		
		collectionView.configureLayout { layout in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.width)
		}
		bottomView.addSubview(collectionView)
		containerView.yoga.applyLayout(preservingOrigin: true)

	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		print("Layout subviews called")
		print(bottomView.yoga.numberOfChildren)
		print(bottomView.subviews)
		containerView.yoga.applyLayout(preservingOrigin: true)
	}
	
	func addBottomView() {
		bottomView = createWrapperView()
		bottomView.yoga.bottom = YGValue(bottomSafeAreaHeight)
		bottomView.yoga.justifyContent = .flexEnd
		containerView.addSubview(bottomView)
		let saveButton = createSaveButton()
		bottomView.addSubview(saveButton)
		
	}
	
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
			layout.paddingHorizontal = 20
			layout.justifyContent = .spaceBetween
			layout.flexDirection = .row
			layout.minHeight = 20
		}
		
		return wrapperView

	}
	
}


