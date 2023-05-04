//
//  AES256Util.swift
//  cereal
//
//  Created by 아프로 on 2022/03/08.
//  Copyright © 2022 srkang. All rights reserved.
//

import Foundation
import CryptoSwift
 
//라이브러리 : https://github.com/krzyzanowskim/CryptoSwift
//pod 'CryptoSwift', '~> 1.3.8'
class AES256Util {
    //키값 32바이트: AES256(24bytes: AES192, 16bytes: AES128)
    private static var SECRET_KEY = "\(Date().ticks)"
//    private static let IV = "\(Date().ticks)"
//
//    private static var SECRET_KEY = "OG20220314154426"
    private static let IV = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
 
    static func encrypt(string: String, timestamp: String) -> String {
        guard !string.isEmpty else { return "" }
        return try! getAESObject(timestamp: timestamp).encrypt(string.bytes).toBase64() ?? ""
    }
 
    static func decrypt(encoded: String, timestamp: String) -> String {
        let datas = Data(base64Encoded: encoded)
 
        guard datas != nil else {
            return ""
        }
 
        let bytes = datas!.bytes
        let decode = try! getAESObject(timestamp: timestamp).decrypt(bytes)
 
        return String(bytes: decode, encoding: .utf8) ?? ""
    }
 
    private static func getAESObject(timestamp: String) -> AES{
        
        let key =  SharedDefaults.getKeyChainCustItem()!.user_no!.prefix(3) + timestamp
        Slog("key::\(key)")
    
        let keyDecodes : Array<UInt8> = Array(key.utf8)
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), padding: .pkcs5) 
        return aesObject
    }
    
    
}

extension Date {
    var ticks: UInt64 {
//        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_0)
        
        return UInt64(Int64(Date().timeIntervalSince1970 * 1000))
    }
    

}

