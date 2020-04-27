//
//  UIViewController.swift
//  InstaStories
//
//  Created by Nika Shelia on 15.04.20.
//  Copyright © 2020 Nika Shelia. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	func showMessage(title: String, description: String ) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
		self.present(alert, animated: true, completion: nil)
	}
}


