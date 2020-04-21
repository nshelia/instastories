//
//  ColorsCollectionView.swift
//  InstaStories
//
//  Created by Nika Shelia on 20.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit
import YogaKit
import RxSwift
import RxCocoa

class ColorsCollectionView : UIView {
	
	let bag = DisposeBag()
	
	private var viewModel: ColorsViewModel  = {
		return ColorsViewModel()
	}()

	let cellReuseIdentifier = "ColorCell"

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(collectionView)
		bindViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	lazy var collectionView : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		cv.configureLayout { layout in
			layout.isEnabled = true
			layout.height = 100
		}
		cv.backgroundColor = .clear
		cv.delegate = self
		cv.register(ColorCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		cv.yoga.applyLayout(preservingOrigin: true)
		return cv
	}()
	
	
	func bindViews() {
		viewModel.colors.asObservable()
			.bind(to: self.collectionView.rx.items(cellIdentifier: cellReuseIdentifier, cellType: ColorCell.self)) { (row, color, cell) in
				cell.configure(color: color)
		}
		.disposed(by: bag)
	}
	
}

extension ColorsCollectionView: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.colors.value.count
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 50, height: 50)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
		return 1
	}
}
