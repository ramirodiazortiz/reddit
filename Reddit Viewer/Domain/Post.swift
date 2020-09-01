//
//  Post.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

class Post: NSObject, Decodable {

	let author: String
	let entryDateTimestamp: Int
	let id: String
	let numberOfComments: Int
	let thumbnailUrl: String?
	let title: String

	enum CodingKeys: String, CodingKey {
		case author
		case data
		case entryDateTimestamp = "created_utc"
		case id
		case numberOfComments = "num_comments"
		case thumbnailUrl = "thumbnail"
		case title
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
			.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
		author = try container.decode(String.self, forKey: .author)
		entryDateTimestamp = try container.decode(Int.self, forKey: .entryDateTimestamp)
		id = try container.decode(String.self, forKey: .id)
		numberOfComments = try container.decode(Int.self, forKey: .numberOfComments)
		thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
		title = try container.decode(String.self, forKey: .title)
	}

}
