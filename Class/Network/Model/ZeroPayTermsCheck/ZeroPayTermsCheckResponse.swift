//
//  ZeroPayTermsCheckResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/05.
//

import Foundation

/**
 제로페이 간편결제 약관동의 여부 확인 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.07.05
*/
struct ZeroPayTermsCheckResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
        
    /// 메인 데이터 입니다.
    var _data        : AgressData?    { get { return data != nil ? data : nil } }
    /// 메인 데이터 입니다.
    var data        : AgressData?
}


/**
 제로페이 간편결제 약관동의 여부 데이터 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.07.05
*/
struct AgressData : Codable
{
    /// 동의여부 입니다.
    var _didAgree  : Bool? { get { return  NC.B(didAgree) } }
    /// 동의여부 입니다.
    var didAgree   : Bool?
}

