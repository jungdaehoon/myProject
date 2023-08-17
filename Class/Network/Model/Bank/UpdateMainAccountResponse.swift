//
//  UpdateMainAccountResponse.swift
//  cereal
//
//  Created by OKPay on 2023/08/16.
//

import Foundation


/**
 계좌 메인 주계좌 요청 입니다 ( J.D.H VER : 2.0.2 )
 - Date: 2023.08.16
*/
struct UpdateMainAccountResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
}
