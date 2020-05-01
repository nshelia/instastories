//
//  StickersCollectionViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 01.05.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import YogaKit

class StickersCollectionViewController: UIViewController, UIGestureRecognizerDelegate {
	
	let bag = DisposeBag()
	
	var collectionView: UICollectionView!

	private let viewModel: StickersViewModel!
	
	let cellReuseIdentifier = "StickerCell"
	
	init(viewModel: StickersViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("App crashed")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		visualEffectView.frame = self.view.bounds
		
		self.view.addSubview(visualEffectView)
		let path = UIBezierPath(roundedRect: visualEffectView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 8.0, height: 8.0))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		visualEffectView.layer.mask = mask
		
		setupView()
		bindViews()

		collectionView.delegate = self

	}

	func bindViews() {
		viewModel.stickers.asObservable()
			.bind(to: self.collectionView.rx.items(cellIdentifier: cellReuseIdentifier, cellType: StickerCell.self)) { (row, image, cell) in
				cell.configure(image: image)
		}
		.disposed(by: bag)
	}
	
	func setupView() {
		
		let flowLayout = UICollectionViewFlowLayout()
		collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
		collectionView.frame.size.height = 700
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		collectionView.register(StickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		collectionView.backgroundColor = .clear
		
		self.view.addSubview(collectionView)
	
	}
	
}

extension StickersCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.stickers.value.count
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let image = viewModel.stickers.value[indexPath.row]
		
		viewModel.imageSelected.accept(image)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.bounds.width
		let cellWidth = (width) / 4
		return CGSize(width: cellWidth, height: cellWidth)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
		return 1
	}
}
