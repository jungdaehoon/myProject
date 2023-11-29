//
//  AtmAgreementResponse.swift
//  cereal
//
//  Created by OKPay on 2023/11/28.
//

import Foundation


/**
  ATM 약관동의 여부 조회 입니다.  (  ( J.D.H VER : 2.0.7 )
 - Date: 2023.11.28
*/
struct AtmAgreementResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
    
    /// 약관 동의 요청 여부 입니다.
    var _atmAgreeChk        : Bool? { get { return  NC.B(atmAgreeChk) } }
    /// 약관 동의 요청 여부 입니다.
    var atmAgreeChk         : Bool?
}
