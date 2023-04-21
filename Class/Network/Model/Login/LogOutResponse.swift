//
//  LogOutResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/20.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation

/**
 로그아웃 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
*/
struct LogOutResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
}
