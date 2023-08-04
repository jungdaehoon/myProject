//
//  Data.swift
//  cereal
//
//  Created by OKPay on 2023/08/04.
//

import Foundation

extension Data
{
    var kbyte : String {
        let byteCount                        = Int64(self.count) // replace with data.count
        let bcf                              = ByteCountFormatter()
        bcf.allowedUnits                     = [.useKB] // optional: restricts the units to MB only
        bcf.countStyle                       = .file
        return bcf.string(fromByteCount: byteCount)
    }
    
    var mbyte : String {
        let byteCount                        = Int64(self.count) // replace with data.count
        let bcf                              = ByteCountFormatter()
        bcf.allowedUnits                     = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle                       = .file
        return bcf.string(fromByteCount: byteCount)
    }
    
}
