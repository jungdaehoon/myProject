//
//  KeyChainCustItem.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation


/**
 공통으로 확인체크 하는 고객 정보를 저장 합니다.   ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.16
 */
class KeyChainCustItem: NSObject , NSCoding {
    /// 마지막 접속 시간 입니다.
    var last_login_time : String?
    /// 로그인 토큰 정보 입니다.
    var token : String?
    /// 고객 넘버 입니다.
    var user_no : String?
    /// 휴대폰 정보 입니다.
    var user_hp : String?
    /// 자동 로그인 여부 입니다.
    var auto_login : Bool = false
    /// fcm 연결 토큰 정보 입니다.
    var fcm_token : String?
    
    
    struct PropertyKey {
        static let kLast_login_time = "Last_login_time"
        static let kToken = "token"
        static let kUser_no = "user_no"
        static let kUser_hp = "user_hp"
        static let kAuto_login = "auto_login"
        static let kFcm_token = "fcm_token"
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(last_login_time, forKey: PropertyKey.kLast_login_time)
        aCoder.encode(token, forKey: PropertyKey.kToken)
        aCoder.encode(user_no, forKey: PropertyKey.kUser_no)
        aCoder.encode(user_hp, forKey: PropertyKey.kUser_hp)
        aCoder.encode(auto_login, forKey: PropertyKey.kAuto_login)
        aCoder.encode(fcm_token, forKey: PropertyKey.kFcm_token)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        if let last_login_time = aDecoder.decodeObject(forKey: PropertyKey.kLast_login_time)  {
            self.last_login_time = last_login_time as? String
        }
        
        if let token = aDecoder.decodeObject(forKey: PropertyKey.kToken) {
            self.token = token as? String
        }
        
        if let user_no = aDecoder.decodeObject(forKey: PropertyKey.kUser_no) {
            self.user_no = user_no  as? String
        }
        
        if let user_hp = aDecoder.decodeObject(forKey: PropertyKey.kUser_hp) {
            self.user_hp = user_hp  as? String
        }
        
        self.auto_login = aDecoder.decodeBool(forKey: PropertyKey.kAuto_login)
        
        if let fcm_token = aDecoder.decodeObject(forKey: PropertyKey.kFcm_token) {
            self.fcm_token = fcm_token  as? String
        }
            
//
    }
    

    
}
