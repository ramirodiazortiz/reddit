//
//  Date+Extension.swift
//  reddit
//
//  Created by Ramiro Diaz on 01/09/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

extension Date {

	//Note: This could be improved by using NSStringLocalizedFormatKey properly
	var relativeTime: String {
		let interval = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: self, to: Date())
		if let day = interval.day, day > 0 {
			return "\(day) \(NSLocalizedString("DaysAgo", comment: ""))"
		} else if let hour = interval.hour, hour > 0 {
			return "\(hour) \(NSLocalizedString("HoursAgo", comment: ""))"
		} else if let minute = interval.minute, minute > 0 {
			return "\(minute) \(NSLocalizedString("MinutesAgo", comment: ""))"
		} else if let second = interval.second, second > 0 {
			return "\(second) \(NSLocalizedString("SecondsAgo", comment: ""))"
		} else {
			return ""
		}
	}
}
