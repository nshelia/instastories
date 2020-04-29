//
//  EditorViewController+TextView.swift
//  InstaStories
//
//  Created by Nika Shelia on 29.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

extension EditorViewController: UITextViewDelegate {
	
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		
		if self.activeTextView != nil{
			return false
		}
		return true
	}
	
	func typingSizeForTextView(textView: UITextView) -> CGSize {
		let fitSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
		
		return fitSize
	}
	
	func lastFrameForTextView(textView: UITextView) -> CGRect? {
		// This means that this text view is new and doesn't have any origin.
		if textView.superview?.frame.origin.x == 0 {
			return nil
		} else {
			return textView.superview?.frame
		}
	}
	
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		self.textViewLastTransform = textView.superview?.transform
		self.textViewLastFrame = self.lastFrameForTextView(textView:textView)
		
		UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .curveEaseInOut, animations: {
			textView.superview?.transform = .identity
			self.textViewDidChange(textView)
		})
		
		
		self.activeTextView = textView
		
		moveCollectionView(up: true)
		self.viewModel.visibleScene.accept(.addingTextField)
	}
	
	func moveCollectionView(up: Bool) {
		let threshold = self.keyboardHeight - Constants.bottomSafeAreaHeight
		if up {
			colorsCollectionViewController.view.frame.origin.y -= threshold
		} else {
			colorsCollectionViewController.view.frame.origin.y += threshold
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if let text = textView.text, text.count == 0 {
			textView.superview?.removeFromSuperview()
		}
		
		UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4, options: .curveEaseInOut, animations: {
			if let frame = self.textViewLastFrame {
				textView.superview?.center = frame.center
			}
			
			if let transform = self.textViewLastTransform {
				textView.superview?.transform = transform
				
			}
			self.moveCollectionView(up: false)
		}, completion: { bool in
			self.activeTextView = nil
		})
	}
	
	func textViewDidChange(_ textView: UITextView) {
		textView.textAlignment = .center
		let size = typingSizeForTextView(textView: textView)
		textView.frame = CGRect(origin: textView.frame.origin, size: size)
		textView.superview?.frame.size = size
		textView.superview?.frame.origin = CGPoint(x: self.view.center.x - (size.width / 2),y: (self.view.frame.size.height -  self.keyboardHeight) / 2)
		
	}
}


