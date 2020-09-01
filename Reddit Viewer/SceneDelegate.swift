//
//  SceneDelegate.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let window = window else { return }
		guard let splitViewController = window.rootViewController as? UISplitViewController else { return }
		guard let navigationController = splitViewController.viewControllers.last as? UINavigationController else { return }
		splitViewController.preferredDisplayMode = .allVisible
		navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
		navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
	}

}

