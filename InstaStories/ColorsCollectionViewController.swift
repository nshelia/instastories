//
//  ColorsCollectionViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 23.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YogaKit

class ColorsCollectionViewController: UIViewController {
	
	let bag = DisposeBag()

	private let viewModel: ColorsViewModel!

	override func viewDidLoad() {
			super.viewDidLoad()

	}
	
	let cellReuseIdentifier = "ColorCell"

	
	init(viewModel: ColorsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.view.addSubview(collectionView)
		bindViews()
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("App crashed")
	}
	
	
	lazy var collectionView : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = Constants.collectionViewCellGutter
		let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		cv.configureLayout { layout in
			layout.isEnabled = true
			layout.height = YGValue(Constants.collectionViewCellWidth)
		}
		cv.showsHorizontalScrollIndicator = false
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

extension ColorsCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.colors.value.count
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.colors.accept(viewModel.colors.value.enumerated().map { (index,item) in
			return Color(value: item.value, isActive: index == indexPath.row)
		})
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: Constants.collectionViewCellWidth, height: Constants.collectionViewCellWidth)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
		return 1
	}
}
