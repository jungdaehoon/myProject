//
//  AtmInsertAgreementResponse.swift
//  cereal
//
//  Created by OKPay on 2023/11/28.
//

import Foundation


/**
  ATM 약관동의 요청 입니다.  (  ( J.D.H VER : 2.0.7 )
 - Date: 2023.11.28
*/
struct AtmInsertAgreementResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
}
