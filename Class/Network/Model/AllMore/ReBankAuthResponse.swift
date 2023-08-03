//
//  ReBankAuthResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/21.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation


/**
 은행계좌 재인증 요청 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.22
*/
struct ReBankAuthResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
    
    /// 계좌 재인증할 URL 정보입니다.
    var _gateWayURL              : String? { get { return  NC.S(gateWayURL) } }
    
    /// 계좌 재인증할 URL 정보입니다.
    var gateWayURL : String?
}
