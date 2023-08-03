//
//  Int.swift
//  MyData
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation

extension Int {
    func addComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    func toHex() -> String {
        return String(format:"%02X", self)
    }
}

extension UInt
{
    func addComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
