//
//  String+Extension.swift
//  reddit
//
//  Created by Ramiro Diaz on 03/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

extension String {
	
	///Returns a query items dictionary from the string
	var toQueryDictionary: [String: String] {
		return self.components(separatedBy: "&").map({
			$0.components(separatedBy: "=")
		}).reduce(into: [String:String]()) { dict, pair in
			if pair.count == 2 {
				dict[pair[0]] = pair[1]
			}
		}
	}
}
	
