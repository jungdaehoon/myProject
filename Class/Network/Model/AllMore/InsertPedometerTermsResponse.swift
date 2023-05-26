//
//  InsertPedometerTermsResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation


/**
 만보GO 약관 "동의"를 요청 합니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.15
*/
struct InsertPedometerTermsResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
}
