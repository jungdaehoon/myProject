//
//  PedometerUpdateResponse.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation


/**
 만보기 정보 업데이트 입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.23
*/
struct PedometerUpdateResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
}
