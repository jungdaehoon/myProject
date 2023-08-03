//
//  BaseResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/08.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation

/**
 기본 베이스 네트워크 인터페이스 Response 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.15
 */
protocol BaseResponse: Codable {
    /// 세부 응답코드 입니다.
    var result_cd   : String? { get }
    /// 세부 응답메세지 입니다.
    var result_msg  : String? { get }
    /// 세부 응답코드 입니다.
    var code        : String? { get }
    /// 세부 응답메세지 입니다.
    var msg         : String? { get }
}
