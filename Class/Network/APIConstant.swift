//
//  APIConstant.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation



/**
 API 인터페이스 정보입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.23
*/
class APIConstant {
    /// 앱 시작시 기본 사항 요청 입니다.
    static let API_START_APP            = "/api/start.do"
    /// 로그인 요청 입니다.
    static let API_LOGIN                = "/api/login.do"
    /// 로그아웃 요청 입니다.
    static let API_LOGOUT               = "/api/logout.do"
    /// 계좌 등록여부 조회 요청 입니다.
    static let API_ACCOUNT_LIST         = "/myp/selectAccountList.do"
    /// FCM 푸시 토큰을 등록 요청 입니다.
    static let API_PUSH_TOKEN           = "/api/pushToken.do"
    /// 전체 탭 관련 정보를 요청 합니다.
    static let API_MYALL_MENU           = "/all/selectMyInfo.do"
    /// 계좌 재인증 요청 입니다.
    static let API_AUTH_ACCOUNT         = "/openbank/authorizeAccount.do"
    /// 오늘의 만보기 정보를 요청 합니다.
    static let API_GET_PEDOMETER        = "/myp/selectMyPedometer.do"
    /// 만보기 리워드 요청 합니다.
    static let API_GET_PEDOMETER_REWARD = "/myp/insertPedometer.do"
    /// 만보기 업데이트 입니다.
    static let API_UPDATE_PEDOMETER     = "/myp/updateDailyPedometer.do"
    /// 만보기 약관동의 여부 요청 입니다.
    static let API_PEDO_TERMS_CHECK     = "/popup/selectPedometerTerms.do"
    /// 만보기 약관 동의 입니다.
    static let API_PEDO_TERMS_AGREE     = "/popup/insertPedometerTerms.do"
    /// QRCode 인증 할 제로페이 스크립트를 요청 합니다.
    static let API_ZEROPAY_QRCODE       = "/api/v1/zeropay/qrcode.do"
}
