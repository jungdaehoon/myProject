//
//  ZeroPayQRCodeStatusResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/05.
//

import Foundation

/**
 캔된 QRCode 정보를 정상여부 체크 합니다. (  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.07.05
*/
struct ZeroPayQRCodeStatusResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
    
    /// 메인 데이터 입니다.
    var _data        : statusdata?    { get { return data != nil ? data : nil } }
    /// 메인 데이터 입니다.
    var data        : statusdata?
}


struct statusdata : Codable
{
    /// 사용 가능여부를 받습니다. ( S : 정지, A : 사용가능 )
    var _status  : String? { get { return  NC.S(status) } }
    /// 사용 가능여부를 받습니다. ( S : 정지, A : 사용가능 )
    var status   : String?
}
