//
//  NSObject.swift
//  MyData
//
//  Created by DaeHoon Chung on 2023/03/07.
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
