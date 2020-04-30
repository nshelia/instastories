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
import NotificationCenter

class EditorViewController: UIViewController, UIGestureRecognizerDelegate {
	
	let gestureShadowView = UIView(frame: .zero)
	
	var initialCenter = CGPoint()
	
	let bag = DisposeBag()
	
	var initialImage: PhotoView
	
	let viewModel: EditorViewModel!
		
	var imageView: UIImageView!
	
	// CHILD CONTROLLERS
	var colorsCollectionViewController: ColorsCollectionViewController!
	
	// VIEWS
	var sceneNavigatorView: UIView!
	var saveView: UIView!
	var completionView: UIView!
	var trashView: TrashView!
	
	// GESTURES
	let pinchGesture = UIPinchGestureRecognizer()
	let continiousGesture = TouchCaptureGesture(coder: NSCoder())
	let panGesture = UIPanGestureRecognizer()
	let rotationGesture = UIRotationGestureRecognizer()
	
	// BUTTONS
	var closeButton: UIButton!
	var saveButton: UIButton!
	var doneButton: UIButton!
	
	// TEXTVIEWS
	var activeTextView: UITextView!
	var textViewLastFrame: CGRect!
	var textViewLastTransform: CGAffineTransform?

	var currentDrawingColor: UIColor = Constants.colors.first!
	
	var currentlyMoving = BehaviorRelay<ClosestView?>(value: nil)

	var keyboardHeight: CGFloat = 0
	
	let drawingPaper: UIView = {
		let view = UIView()
		
		view.configureLayout { (layout) in
			layout.isEnabled = true
		}
		
		view.accessibilityIdentifier = "DrawingPaper"
		
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
		self.view.yoga.isEnabled = true
		self.view.backgroundColor = .black
		self.navigationItem.title = "Photo Editor"
		self.navigationController?.navigationBar.isHidden = true
		
		drawingPaper.yoga.width = YGValue(self.view.bounds.size.width)
		drawingPaper.yoga.height = YGValue(self.view.bounds.size.height)

		self.view.addSubview(drawingPaper)
		
		setupImageView()
		addMainScene()
		addDrawingScene()
		addGestures()
		
		viewModel.addItem(item: initialImage)
		viewModel.fetchOriginalImage(localIdentifier: initialImage.localIdentifier)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
	
	}
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			keyboardHeight = keyboardSize.height
		}
	}

	
	// MARK: Main Scene
	
	func addMainScene() {
		let viewModel = SceneNavigatorViewModel()
		
		viewModel.closeButtonPress.subscribe(onNext: {
			let transition: CATransition = CATransition()
			transition.duration =	0.3
			transition.type = CATransitionType.fade
			self.navigationController?.view.layer.add(transition, forKey: nil)
			self.navigationController?.popViewController(animated: false)
		}).disposed(by: bag)
		
		viewModel.brushButtonPress.subscribe(onNext: {
			self.viewModel.visibleScene.accept(.drawing)
		}).disposed(by: bag)
			
		viewModel.textFieldButtonPress.subscribe(onNext: {
			self.viewModel.visibleScene.accept(.addingTextField)
		}).disposed(by: bag)
		
		sceneNavigatorView = SceneNavigatorView(viewModel: viewModel, frame:.zero)
		
		saveView = SaveView(frame: .zero)
		trashView = TrashView(frame: .zero)
		
		trashView.isHidden = true
		
		self.view.addSubview(sceneNavigatorView)
		self.view.addSubview(saveView)
		self.view.addSubview(trashView)
		self.view.bringSubviewToFront(sceneNavigatorView)
		self.view.bringSubviewToFront(saveView)
		self.view.bringSubviewToFront(trashView)
		
		self.view.yoga.applyLayout(preservingOrigin: true)


	}
	
	// MARK: Drawing Scene
	
	func addDrawingScene() {

		let completionViewModel = CompletionViewModel()
		
		completionViewModel.doneButtonPress.subscribe(onNext: {
			self.viewModel.visibleScene.accept(.main)
		}).disposed(by: bag)
		
		
		completionView = CompletionView(viewModel: completionViewModel, frame: .zero)

		self.view.addSubview(completionView)
		
		let viewModel = ColorsViewModel()

		viewModel.colors.map { $0.first{ $0.isActive} }.subscribe(onNext: { activeColor in
			self.currentDrawingColor = activeColor!.value
			self.activeTextView?.textColor = self.currentDrawingColor
		}).disposed(by: bag)
		
		colorsCollectionViewController = ColorsCollectionViewController(viewModel: viewModel)
		
		colorsCollectionViewController.view.configureLayout { layout in
			layout.isEnabled = true
			layout.position = .absolute
			layout.bottom = YGValue(Constants.bottomSafeAreaHeight)
			layout.width = YGValue(self.view.bounds.width)
			layout.height = 50
		}
		
		self.view.addSubview(colorsCollectionViewController.view)
		
		colorsCollectionViewController.willMove(toParent: self)
		colorsCollectionViewController.didMove(toParent: self)
		
		self.addChild(colorsCollectionViewController)
		colorsCollectionViewController.view.yoga.applyLayout(preservingOrigin: true)
		self.view.yoga.applyLayout(preservingOrigin: true)
		
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
		
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	// MARK: Selected Image
	
	func setupImageView() {
		imageView = UIImageView(frame: self.view.bounds)
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = true
		imageView.isMultipleTouchEnabled = true
		imageView.backgroundColor = .clear
		
		let canvasItem = CanvasItem(minimumNumberOfTouches: 2, frame:imageView.bounds)
		
		canvasItem.addSubview(imageView)
		drawingPaper.addSubview(canvasItem)
	}

	override func viewDidAppear(_ animated: Bool) {
		bindViews()
	}

	func mainScene(visible: Bool) {
		sceneNavigatorView.isHidden = !visible
		saveView.isHidden = !visible
	}
	
	func drawingScene(visible: Bool) {
		completionView?.isHidden = !visible
		colorsCollectionViewController?.view.isHidden = !visible
	}
 
	func multiTouchGestures(enable: Bool) {
		pinchGesture.isEnabled = enable
		panGesture.isEnabled = enable
		rotationGesture.isEnabled = enable
	}
	
	func bindViews() {
		
		currentlyMoving.subscribe(onNext: { item in
			if item != nil {
				self.mainScene(visible: false)
				if item?.minimumNumberOfTouches == 1 {
					self.trashView.isHidden = false
				}
			} else {
				self.mainScene(visible: true)
				self.trashView.isHidden = true
			}
		}).disposed(by: bag)
		
		viewModel.visibleScene.subscribe(onNext: { currentScene in
			switch currentScene {
				case .main:
					self.view.endEditing(true)

					self.mainScene(visible: true)
					self.drawingScene(visible: false)
					self.continiousGesture?.isEnabled = false
				
					self.multiTouchGestures(enable: true)

				case .drawing:
					self.view.endEditing(true)

					self.mainScene(visible: false)
					self.drawingScene(visible: true)
					self.continiousGesture?.isEnabled = true
					
					self.multiTouchGestures(enable: false)

				case .addingTextField:
					self.mainScene(visible: false)
					self.drawingScene(visible: true)
					self.continiousGesture?.isEnabled = false

					self.multiTouchGestures(enable: false)
					
					if self.activeTextView == nil {
						self.createTextView()
					}
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
		drawingPaper.addGestureRecognizer(rotationGesture)
		drawingPaper.addGestureRecognizer(pinchGesture)
		drawingPaper.addGestureRecognizer(panGesture)
		drawingPaper.addGestureRecognizer(continiousGesture!)

	}
	
	func createTextView() {
		let canvasItem = CanvasItem(minimumNumberOfTouches: 1, frame: .zero)
		let textView = UITextView()
		textView.backgroundColor = .clear
		textView.isScrollEnabled = false
		textView.textAlignment = .center
		textView.font = .boldSystemFont(ofSize: 35)
		textView.textColor = self.currentDrawingColor
		textView.delegate = self
		canvasItem.addSubview(textView)
		drawingPaper.addSubview(canvasItem)
		
		
		textView.becomeFirstResponder()
		
		textViewDidChange(textView)


	}
	
}
