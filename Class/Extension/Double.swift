//
//  Double.swift
//  MyData
//
//  Created by INTAEK HAN on 2022/04/20.
//

import Foundation

extension Double {
    func addComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    /**
     소수점 이하 2자리
     */
    func pointTwo() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
