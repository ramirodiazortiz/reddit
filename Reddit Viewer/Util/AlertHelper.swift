//
//  AlertHelper.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class AlertHelper: UIView {

	static func showOkAlert(title: String, message: String, presenter: UIViewController) {
		showAlert(title: title, message: message, okText: "Ok", cancelText: nil, okHandler: nil, presenter: presenter)
	}
	
	static func showAlert(title: String,
						  message: String,
						  okText: String,
						  cancelText: String?,
						  okHandler: (() -> Void)?,
						  presenter: UIViewController) {
		let alert = UIAlertController(
			title: NSLocalizedString(title, comment: ""),
			message: NSLocalizedString(message, comment: ""),
			preferredStyle: UIAlertController.Style.alert
		)
		alert.addAction(
			UIAlertAction(title: NSLocalizedString(okText, comment: ""), style: UIAlertAction.Style.default
		) { [weak alert] (action: UIAlertAction!) in
			alert?.dismiss(animated: true, completion: okHandler)
		})
		if let cancelText = cancelText {
			alert.addAction(
				UIAlertAction(title: NSLocalizedString(cancelText, comment: ""), style: UIAlertAction.Style.default
			) { [weak alert] (action: UIAlertAction!) in
				alert?.dismiss(animated: true, completion: nil)
			})
		}
		presenter.present(alert, animated: true, completion: nil)
	}

}
