//
//  HomeViewModel.swift
//  InstaStories
//
//  Created by Nika Shelia on 13.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

enum PhotoAccessError: Error{
	case failure(reason: String)
}

final class HomeViewModel {
        
    private var disposeBag = DisposeBag()
	
    public func requestStatus() -> Single<Bool> {
			return Single<Bool>.create { single in
				let authState = PHPhotoLibrary.authorizationStatus()
				
					switch authState {
						case .authorized:
							single(.success(true))
						default:
							PHPhotoLibrary.requestAuthorization { newStatus in
								single(.success(newStatus == .authorized))
							}
					}
				return Disposables.create()
			}
    }
    
}
