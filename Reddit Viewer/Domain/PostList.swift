//
//  Post.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class PostList: NSObject, Decodable {

	let data: [Post]

	enum CodingKeys: String, CodingKey {
		case data
		case children
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
			.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
		self.data = try container.decode([Post].self, forKey: .children)
	}

}
