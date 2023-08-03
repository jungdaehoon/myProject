//
//  PedometerTermsAgreeResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/09.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation

/**
 만보GO 약관동의 여부를 체크 합니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.22
*/
struct PedometerTermsAgreeResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
    
    /// 약관 동의 여부 정보를 받습니다.
    var _data       : use_data? { get { return data != nil ? data : use_data() } }
    /// 유저 넘버 입니다.
    var _user_no    : String? { get { return  NC.S(user_no) } }
    
    /// 약관 동의 여부 정보를 받습니다.
    var data        : use_data?
    /// 유저 넘버 입니다.
    var user_no     : String?
}

/**
 만보GO 약관동의 여부를 정보 데이터 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.22
*/
struct use_data: Codable {
    /// 약관동의 여부 값을 받습니다.
    var _pedometer_use_yn             : String? { get { return  NC.S(pedometer_use_yn) } }
    
    /// 약관동의 여부 값을 받습니다.
    var pedometer_use_yn : String?    
}
