//
//  ResponseError.swift
//  
//
//  Created by UMC on 2022/01/04.
//

import Foundation

let NETWORK_ERR_MSG             = "네트워크 연결 상태가 좋지 않습니다"
let NETWORK_ERR_MSG_DETAIL      = "휴대폰 연결 상태를 확인해주세요."
let TIMEOUT_ERR_MSG             = "통신 중 일시적인 오류가 발생했습니다"
let TIMEOUT_ERR_MSG_DETAIL      = "앱 종료 후 다시 실행해주세요."
let TEMP_NETWORK_ERR_MSG        = "안내"
let TEMP_NETWORK_ERR_MSG_DETAIL = "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오."

let PARSING_ERR_MSG = "응답 데이터 파싱 오류가 발생하였습니다."
let DATABSE_ERR_MSG = "데이터베이스 에러가 발생하였습니다."

enum ResponseError: Error {
    case http(ErrorData)
    case parsing(String)
    case unknown(String)
    case timeout(String)
}

enum ResponseCode: String {
    case success = "00000"              //정상
    case abnormal_parameter = "40001"   //요청값이 유효하지 않을 경우
    case abnormal_header = "40002"      //헤더 값 미존재 또는 잘못된 헤더값인 경우
    case abnormal_token = "40101"       //유효하지 않은 접근토큰
    case abnormal_api = "40301"         //올바르지 않은 API 호출
    case abnormal_none = "40401"        //존재하지 않음
    case abnormal_user = "40403"        //정보주체(고객) 미존재
    case abnormal_request = "40501"     //API가 허용하지 않는 HTTP Method 요청의 경우
    case abnormal_failure = "50002"     //API 요청 처리 실패
    case request_time_out = "50003"     //처리시간 초과 에러
    case service_check = "50008"        //시스템 정기점검
    case unknown //= "50004"            //알 수 없는 에러
    //extra
    case certificate_failure = "70000"
    case other_device_joined_user = "80000"    //단말기 중복 가입된 경우
    case under_age_user = "90000"       //미성년
}

struct ErrorData {
    var code: Int
    var message: String
}
