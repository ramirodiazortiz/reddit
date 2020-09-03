//
//  TopPostListFooter.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class TopPostListFooter: UIView {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView?
	@IBOutlet weak var dismissAllButton: UIButton?
	
	func setup(target: Any, selector: Selector) {
		dismissAllButton?.addTarget(target, action: selector, for: .touchUpInside)
		dismissAllButton?.setTitle(NSLocalizedString("DismissAll", comment: ""), for: .normal)
	}

	func swithToLoadingState(isLoading: Bool) {
		activityIndicator?.isHidden = !isLoading
		dismissAllButton?.isHidden = isLoading
	}

	func hideDismissButton(hide: Bool) {
		dismissAllButton?.isHidden = hide
	}
	
	func hideLoader(hide: Bool) {
		activityIndicator?.isHidden = hide
	}
}
