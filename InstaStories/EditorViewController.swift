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
	
	// CHILD CONTROLLERS
	
	var colorsCollectionViewController: ColorsCollectionViewController!
	
	// GESTURES
	let pinchGesture = UIPinchGestureRecognizer()
	let continiousGesture = TouchCaptureGesture(coder: NSCoder())
	let panGesture = UIPanGestureRecognizer()
	let rotationGesture = UIRotationGestureRecognizer()
	
	// BUTTONS
	var closeButton: UIButton!
	var drawButton: UIButton!
	var saveButton: UIButton!
	var doneButton: UIButton!
	
	// DRAWING PAPER
	
	var currentDrawingColor: UIColor = Constants.colors.first!
	
	let mainScene: UIView =  {
		let view = UIView()
		
		view.configureLayout { (layout) in
			layout.isEnabled = true
			layout.paddingHorizontal = 0
			layout.justifyContent = .spaceBetween
			layout.flexDirection = .column
		}
		
		view.accessibilityIdentifier = "MainScene"

				
		return view
	}()
	
	let drawingScene: UIView =  {
		let view = UIView()
		
		view.configureLayout { (layout) in
			layout.isEnabled = true
			layout.paddingHorizontal = 0
			layout.justifyContent = .spaceBetween
			layout.flexDirection = .column
		}
		
		view.accessibilityIdentifier = "DrawingScene"
		
		return view
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
		
		mainScene.yoga.width = YGValue(self.view.bounds.size.width)
		mainScene.yoga.height =  YGValue(self.view.bounds.size.height)

		drawingScene.yoga.width = YGValue(self.view.bounds.size.width)
		drawingScene.yoga.height =  YGValue(self.view.bounds.size.height)
		
	
		self.view.addSubview(mainScene)
		self.view.addSubview(drawingScene)
		
		if #available(iOS 11.0, *) {
			let window = UIApplication.shared.windows[0]
			let safeFrame = window.safeAreaLayoutGuide.layoutFrame
			topSafeAreaHeight = safeFrame.minY
			bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
		}
		
		setupImageView()
		bindViews()
		addMainScene()
		addDrawingScene()
		addGestures()
		
		viewModel.addItem(item: initialImage)
		viewModel.fetchOriginalImage(localIdentifier: initialImage.localIdentifier)

	}
	
	func addMainScene() {
		let topView = createWrapperView(topArea: true)
		topView.yoga.justifyContent = .spaceBetween
		let closeButton = createCloseButton()
		topView.addSubview(closeButton)
		let drawButton = createDrawButton()
		topView.addSubview(drawButton)
		
		mainScene.addSubview(topView)
		
		let bottomView = createWrapperView(bottomArea: true)
		bottomView.yoga.justifyContent = .flexEnd
		let saveButton = createSaveButton()
		bottomView.addSubview(saveButton)
		
		mainScene.addSubview(bottomView)
		
		mainScene.yoga.applyLayout(preservingOrigin: true)
	}
	
	func addDrawingScene() {
		let topView = createWrapperView(topArea: true)
		topView.yoga.justifyContent = .flexEnd
		topView.tag = 102

		let doneButton = createDoneButton()
		topView.addSubview(doneButton)
		
		doneButton.rx.tap.subscribe(onNext: { [weak self] in
			self?.viewModel.visibleScene.accept(.main)
		}).disposed(by: bag)
		
		let bottomView = createWrapperView(bottomArea: true)
		bottomView.yoga.justifyContent = .center
		bottomView.tag = 101
		
		let viewModel = ColorsViewModel()
		
		colorsCollectionViewController = ColorsCollectionViewController(viewModel: viewModel)
		colorsCollectionViewController.view.isHidden = true

		colorsCollectionViewController.view.configureLayout { layout in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.width)
		}
		
		viewModel.colors.map { $0.first{ $0.isActive} }.subscribe(onNext: { activeColor in
			self.currentDrawingColor = activeColor!.value
		}).disposed(by: bag)
		
		colorsCollectionViewController.view.frame = bottomView.bounds;
		colorsCollectionViewController.willMove(toParent: self)
		bottomView.addSubview(colorsCollectionViewController.view)
		colorsCollectionViewController.didMove(toParent: self)
		self.addChild(colorsCollectionViewController)
		
		drawingScene.addSubview(topView)
		drawingScene.addSubview(bottomView)

		drawingScene.yoga.applyLayout(preservingOrigin: true)
		

	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		let view = gestureRecognizer.view
		let loc = gestureRecognizer.location(in: view)
		let subview = view?.hitTest(loc, with: nil)
		
		let bottomView = self.view.viewWithTag(101)
		let topView = self.view.viewWithTag(102)
		
		if subview!.isDescendant(of: bottomView!) || subview!.isDescendant(of: topView!) {
			return false
		}
		
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
		viewModel.visibleScene.subscribe(onNext: { currentScene in
			switch currentScene {
				case .main:
					self.view.bringSubviewToFront(self.mainScene)

					self.mainScene.isHidden = false
					self.doneButton?.isHidden = true
					self.continiousGesture?.isEnabled = false
					self.pinchGesture.isEnabled = true
					self.panGesture.isEnabled = true
					self.rotationGesture.isEnabled = true
					self.colorsCollectionViewController?.view?.isHidden = true

				case .drawing:
					self.view.bringSubviewToFront(self.drawingScene)

					self.mainScene.isHidden = true
					self.continiousGesture?.isEnabled = true
					self.pinchGesture.isEnabled = false
					self.panGesture.isEnabled = false
					self.rotationGesture.isEnabled = false
					self.doneButton?.isHidden = false
					self.colorsCollectionViewController?.view?.isHidden = false

			}
		}).disposed(by: bag)
		
		viewModel.photoInView.asDriver(onErrorJustReturn: PhotoView.defaultImage())
			.map({ $0.image})
			.drive(imageView.rx.image).disposed(by: bag)
	}
	
	func addGestures() {

		continiousGesture?.addTarget(self, action: #selector(self.swiper))
		pinchGesture.addTarget(self, action: #selector(handleScale))
		rotationGesture.addTarget(self, action: #selector(handleRotate))
		panGesture.addTarget(self, action: #selector(handlePan))

		rotationGesture.delegate = self
		pinchGesture.delegate = self
		panGesture.delegate = self
		continiousGesture?.delegate = self

		self.view.addGestureRecognizer(rotationGesture)
		self.view.addGestureRecognizer(pinchGesture)
		self.view.addGestureRecognizer(panGesture)
		drawingScene.addGestureRecognizer(continiousGesture!)

	}
	
	func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		let path = UIBezierPath()
		path.move(to: fromPoint)
		path.addLine(to: toPoint)
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = currentDrawingColor.cgColor
		shapeLayer.lineWidth = 5
		
		drawingScene.layer.addSublayer(shapeLayer)
	}
	
	@objc func swiper(_ gestureRecognizer: TouchCaptureGesture) {

		if gestureRecognizer.state == .began {
			doneButton.isHidden = true
			colorsCollectionViewController.view.isHidden = true
		}
		
		if gestureRecognizer.state == .ended {
			doneButton.isHidden = false
			colorsCollectionViewController.view.isHidden = false
		}
		
		if (gestureRecognizer.samples.count > 1) {
			let firstPoint = gestureRecognizer.samples[gestureRecognizer.samples.count - 2].location
			let secondPoint = gestureRecognizer.samples.last!.location
			drawLine(from: firstPoint, to: secondPoint)
		}
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
	
	func createCloseButton() -> UIButton {
		closeButton = createHeaderButton(imageIdentifier: "close")
		
		closeButton.rx.tap.bind {
			let transition: CATransition = CATransition()
			transition.duration =	0.3
			transition.type = CATransitionType.fade
			self.navigationController?.view.layer.add(transition, forKey: nil)
			
			self.navigationController?.popViewController(animated: false)
		}.disposed(by: bag)
		
		return closeButton
	}
	
	func createDrawButton() -> UIButton {
		drawButton = createHeaderButton(imageIdentifier: "brush")
		
		drawButton.rx.tap.bind { [weak self ] _ in
			guard let self = self else { return }
			self.viewModel.visibleScene.accept(.drawing)
		}.disposed(by: bag)
		
		return drawButton
	}
	
	func createDoneButton() -> UIButton {
		doneButton = UIButton(type: .custom)
		doneButton.setTitle("DONE", for: .normal)
		doneButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
		doneButton.configureLayout { (layout) in
			layout.isEnabled = true
		}
		doneButton.isHidden = true
		
		doneButton.rx.tap.subscribe(onNext: { [weak self] in
			self?.viewModel.visibleScene.accept(.main)
		}).disposed(by: bag)
		
		return doneButton
	}

	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		mainScene.yoga.applyLayout(preservingOrigin: true)
		drawingScene.yoga.applyLayout(preservingOrigin: true)

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
	
	func createWrapperView(topArea: Bool = false,bottomArea: Bool = false)  -> UIView{
		let wrapperView = UIView()
		
		wrapperView.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.size.width)
			layout.paddingHorizontal = 20
			layout.flexDirection = .row
			layout.minHeight = 20
			layout.top = topArea ? YGValue(self.topSafeAreaHeight) : 0
			layout.paddingBottom = bottomArea ? YGValue(self.bottomSafeAreaHeight) : 0
		}
		
		return wrapperView

	}
	
}


