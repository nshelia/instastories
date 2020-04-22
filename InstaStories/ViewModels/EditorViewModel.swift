//
//  EditorViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 17.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos



enum EditorScene {
	case main
	case drawing
}


final class EditorViewModel {
	
	private var disposeBag = DisposeBag()
	
	var photoInView = PublishRelay<PhotoView>()
	var visibleScene = BehaviorRelay<EditorScene>(value: .main)
	
	func addItem(item: PhotoView) {
		photoInView.accept(item)
	}
	
	private lazy var imageManager = PHCachingImageManager()
	
	func fetchOriginalImage(localIdentifier: String) {
		
		let allPhotosOptions = PHFetchOptions()
		
		allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: allPhotosOptions)
		
		
		result.enumerateObjects {
			object, index, stop in
			
			let options = PHImageRequestOptions()
			
			options.isSynchronous = false
			options.deliveryMode = .highQualityFormat
			
			
			let aspectRatio = Double(object.pixelWidth) / Double(object.pixelHeight)
			let imageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / CGFloat(aspectRatio))
			
			self.imageManager.requestImage(for: object as PHAsset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
				guard let image = image else { return }
				
				let model = PhotoView(localIdentifier: object.localIdentifier, image: image, aspectRatio: aspectRatio, pixelWidth: object.pixelWidth, pixelHeight: object.pixelHeight)
				
				self.photoInView.accept(model)
				
			})
		}
		
	}
	
}
