//
//  PhotosViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 15.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import UIKit
import YogaKit
import RxSwift


class PhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout{
	
	let bag = DisposeBag()
	
	let cellReuseIdentifier = "PhotoCell"
	
	private let viewModel: PhotosViewModel
	
	var photosCollectionView: UICollectionView!
	
	init(viewModel: PhotosViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("App crashed")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		bindViews()
		viewModel.fetchPhotos()
		
		photosCollectionView.delegate = self
		photosCollectionView.contentOffset = .zero
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.navigationBar.isHidden = false

	}
	
	func bindViews() {
		viewModel.photos.asObservable()
			.bind(to: self.photosCollectionView.rx.items(cellIdentifier: cellReuseIdentifier, cellType: PhotoCell.self)) { (row, photoView, cell) in
				cell.configure(viewModel: photoView)
		}
		.disposed(by: bag)
	}
	
	func setupView() {
		
		let flowLayout = UICollectionViewFlowLayout()
		photosCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
		
		photosCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		photosCollectionView.backgroundColor = UIColor.white
		photosCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		
		self.view.addSubview(photosCollectionView)
		
		self.navigationItem.title = "Choose a photo from gallery"
		
		view.backgroundColor = .systemBlue
		view.configureLayout { (layout) in
			layout.isEnabled = true
			layout.width = YGValue(self.view.bounds.size.width)
			layout.height = YGValue(self.view.bounds.size.height)
			layout.alignItems = .center
			layout.justifyContent = .center
		}
		
		view.yoga.applyLayout(preservingOrigin: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.bounds.width
		let cellWidth = (width) / 4
		
		return CGSize(width: cellWidth, height: cellWidth)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let photoView = viewModel.photos.value[indexPath.row]
		
		let transition: CATransition = CATransition()
		transition.duration = Constants.fadeTransitionDuration
		transition.type = CATransitionType.fade
		self.navigationController?.view.layer.add(transition, forKey: nil)
	
		let viewController = EditorViewController(viewModel: EditorViewModel(), initialImage: photoView)
		
		self.navigationController?.pushViewController(viewController, animated: false)
		
		
	}
	
}


