//
//  ApiCallResult.swift
//  reddit
//
//  Created by Ramiro Diaz on 31/08/2020.
//  Copyright © 2020 Ramiro Diaz. All rights reserved.
//

import UIKit

///Wraps an api call result
enum ApiCallResult<T, U: Error> {
    case success(T)
    case failure(U)
}
