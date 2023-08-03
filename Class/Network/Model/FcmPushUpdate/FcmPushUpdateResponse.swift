//
//  FcmPushUpdateResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/12.
//

import Foundation
/**
 Fcm Token 정보를 업로드 합니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.12
*/
struct FcmPushUpdateResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
}
