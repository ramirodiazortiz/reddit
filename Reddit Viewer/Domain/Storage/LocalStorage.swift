//
//  LocalStorage.swift
//  Reddit Viewer
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

///Simple implementation for a cache using UserDefaults
class LocalStorage: NSObject {

	private var cache: UserDefaults

	/**
	Initialize the cache.
	- parameter storage: UserDefaults used to represent the cache. Default is **.standard**
	*/
	init(storage: UserDefaults = .standard) {
		self.cache = storage
	}

	/**
	Retrieves an array of Type T, according to the key
	- parameter key: key used to find the object in the cache
	- parameter defaultValue: default value returned in case we can't find the object in the cache
	*/
	func getArray<T>(key: String, defaultValue: Array<T>) -> Array<T> {
		return cache.object(forKey: key) as? Array<T> ?? defaultValue
	}

	/**
	Stores an array of Type T, according to the key, in the cache
	- parameter newValue: array value to store in the cache
	- parameter key: key used to map the object in the cache
	*/
	func setArray<T>(_ newValue: Array<T>?, key: String) {
		cache.set(newValue, forKey: key)
	}

}
