//
//  ZeroPayQRCodeResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/19.
//

import Foundation

/**
 QRCode 인증 할 제로페이 스크립트를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.04.19
*/
struct ZeroPayQRCodeResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd       : String?
    /// 세부 응답메세지 입니다.
    var result_msg      : String?
    /// 세부 응답코드 입니다.
    var code            : String?
    /// 세부 응답메세지 입니다.
    var msg             : String?
    
    /// 제로페이 리턴할 콜백 스크립트 입니다.
    var _zeropay_script : String? { get { return  NC.S(zeropay_script) } }
        
    /// 제로페이 리턴할 콜백 스크립트 입니다.
    var zeropay_script  : String?
}
