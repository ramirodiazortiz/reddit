//
//  Dictionary+Extension.swift
//  reddit
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

extension Dictionary where Dictionary.Key == String {

	///Returns a query items using the key values from a dictionary
	var toQueryItems: [URLQueryItem] {
		return self.compactMap {
			if let value = ($1 as? NSObject)?.description {
				return URLQueryItem(name: $0, value: value)
			}
			return nil
		}
	}

}
