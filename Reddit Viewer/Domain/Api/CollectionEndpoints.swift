//
//  CollectionEndpoints.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

enum CollectionEndpoints: Endpoint {

	//limit: maximum number of posts per call
	case topPosts(limit: Int, after: String?)

	//path for each Collection service.
	var path: String {
		switch self {
		case .topPosts:
			return "/top.json"
		}
	}

	//params for each type of post.
	var params: [String: Any]? {
		switch self {
		case .topPosts(let limit, let after):
			if after == nil {
				return ["limit": limit]
			} else {
				return ["limit": limit, "after": after!]
			}
		}
	}

}
