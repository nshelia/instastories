//
//  PhotosViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 15.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

final class PhotosViewModel {
        
    private var disposeBag = DisposeBag()
		
		var photos = BehaviorRelay<[PhotoView]>(value: [])
	
		private lazy var imageManager = PHCachingImageManager()
	
		func fetchPhotos()  {
			
			let allPhotosOptions = PHFetchOptions()
			
			allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
			
			let result = PHAsset.fetchAssets(with: allPhotosOptions)
			var images = [PhotoView]()
			
			result.enumerateObjects {
							object, index, stop in
				
				let aspectRatio = Double(object.pixelWidth) / Double(object.pixelHeight)
				let imageSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / CGFloat(aspectRatio))

				self.imageManager.requestImage(for: object as PHAsset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
						 guard let image = image else { return }
						
					let model = PhotoView(localIdentifier: object.localIdentifier, image: image, aspectRatio: aspectRatio, pixelWidth: object.pixelWidth, pixelHeight: object.pixelHeight)

					images.append(model)
				})
			}
			
			self.photos.accept(images)
	}
}
