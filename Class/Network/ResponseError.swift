//
//  ResponseError.swift
//  
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation

let NETWORK_ERR_MSG             = "네트워크 연결 상태가 좋지 않습니다"
let NETWORK_ERR_404_MSG         = "요청한 정보를 찾을 수 없습니다."
let NETWORK_ERR_MSG_DETAIL      = "네트워크를 연결할 수 없습니다.\n네트워크 상태를 확인해 주세요."

let TIMEOUT_ERR_MSG             = "통신 중 일시적인 오류가 발생했습니다"
let TIMEOUT_ERR_MSG_DETAIL      = "앱 종료 후 다시 실행해주세요."
let TEMP_NETWORK_ERR_MSG        = "안내"
let TEMP_NETWORK_ERR_MSG_DETAIL = "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오."
let PARSING_ERR_MSG             = "응답 데이터 파싱 오류가 발생하였습니다."
let DATABSE_ERR_MSG             = "데이터베이스 에러가 발생하였습니다."

/**
 통신오류 발생시 error 타입 입니다.( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
enum ResponseError: Error {
    /// Http 오류 입니다.
    case http(ErrorData)
    /// 데이터 파싱 오류 입니다.
    case parsing(String)
    /// 예외 오류 입니다.
    case unknown(String)
    /// 타임 아웃 오류 입니다.
    case timeout(String)
}

/**
 http 오류시 저장되는 정보 입니다 .( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
struct ErrorData {
    /// http 오류 코드 정보 입니다.
    var code: Int
    /// http 오류 문구 정보 입니다.
    var message: String
}
