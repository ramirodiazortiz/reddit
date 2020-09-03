//
//  Post.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

struct Post: Decodable {

	let author: String
	let entryDate: Date
	let id: String
	let numberOfComments: Int
	let thumbnailUrl: String?
	let title: String

	enum CodingKeys: String, CodingKey {
		case author
		case data
		case kind
		case entryDateTimestamp = "created_utc"
		case id
		case numberOfComments = "num_comments"
		case thumbnailUrl = "thumbnail"
		case title
	}
	
	init(from decoder: Decoder) throws {
		var container = try decoder.container(keyedBy: CodingKeys.self)
		let kind = try container.decode(String.self, forKey: .kind)
		container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
		author = try container.decode(String.self, forKey: .author)
		let entryDateTimestamp = try container.decode(TimeInterval.self, forKey: .entryDateTimestamp)
		entryDate = Date(timeIntervalSince1970: entryDateTimestamp)
		let id = try container.decode(String.self, forKey: .id)
		self.id = "\(kind)_\(id)"
		numberOfComments = try container.decode(Int.self, forKey: .numberOfComments)
		thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
		title = try container.decode(String.self, forKey: .title)
	}

}

extension Post: Equatable {

	static func == (lhs: Post, rhs: Post) -> Bool {
		return lhs.id == rhs.id
	}

}
