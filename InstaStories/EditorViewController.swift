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
	
	private let viewModel: EditorViewModel!
		
	var imageView: UIImageView!
	
	// CHILD CONTROLLERS
	var colorsCollectionViewController: ColorsCollectionViewController!
	
	// VIEWS
	
	var sceneNavigatorView: UIView!
	var saveView: UIView!
	var completionView: UIView!
	
	// GESTURES
	let pinchGesture = UIPinchGestureRecognizer()
	let continiousGesture = TouchCaptureGesture(coder: NSCoder())
	let panGesture = UIPanGestureRecognizer()
	let rotationGesture = UIRotationGestureRecognizer()
	
	// BUTTONS
	var closeButton: UIButton!
	var saveButton: UIButton!
	var doneButton: UIButton!
		
	var currentDrawingColor: UIColor = Constants.colors.first!
	var currentlyMoving: UIView!

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
		
		self.view.addSubview(sceneNavigatorView)
		self.view.addSubview(saveView)
		self.view.bringSubviewToFront(sceneNavigatorView)
		self.view.bringSubviewToFront(saveView)
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

	func bindViews() {
		viewModel.visibleScene.subscribe(onNext: { currentScene in
			switch currentScene {
				case .main:
					self.view.endEditing(true)
					self.sceneNavigatorView.isHidden = false
					self.completionView?.isHidden = true
					self.saveView.isHidden = false
					self.colorsCollectionViewController?.view.isHidden = true
					self.continiousGesture?.isEnabled = false
					self.pinchGesture.isEnabled = true
					self.panGesture.isEnabled = true
					self.rotationGesture.isEnabled = true

				case .drawing:
					self.view.endEditing(true)
					self.sceneNavigatorView.isHidden = true
					self.saveView.isHidden = true
					self.colorsCollectionViewController.view.isHidden = false
					self.completionView.isHidden = false
					self.continiousGesture?.isEnabled = true
					self.pinchGesture.isEnabled = false
					self.panGesture.isEnabled = false
					self.rotationGesture.isEnabled = false
				
				case .addingTextField:
					self.continiousGesture?.isEnabled = false
					self.pinchGesture.isEnabled = false
					self.panGesture.isEnabled = false
					self.rotationGesture.isEnabled = false
					self.createTextView()
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
		textView.textAlignment = .center
		textView.sizeToFit()
		textView.isScrollEnabled = false
		textView.font = .boldSystemFont(ofSize: 30)
		textView.textColor = .white
		textView.delegate = self
		textView.becomeFirstResponder()
		textView.center = CGPoint(x: self.view.frame.size.width  / 2,
																 y: self.view.frame.size.height / 2)
		canvasItem.addSubview(textView)
		drawingPaper.addSubview(canvasItem)
		
		textViewDidChange(textView)
	}
	
}

extension EditorViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
		textView.frame = CGRect(origin: textView.frame.origin, size: newSize)
	}
}


