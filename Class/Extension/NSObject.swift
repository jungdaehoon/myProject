//
//  NSObject.swift
//  MyData
//
//  Created by dyjung on 2022/01/13.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}
