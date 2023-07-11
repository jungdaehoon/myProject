//
//  APIConstant.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation



/**
 API 인터페이스 정보입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.23
*/
class APIConstant {
    /// 앱 시작시 기본 사항 요청 입니다.
    static let API_START_APP            = "/api/start.do"
    /// 로그인 요청 입니다.
    static let API_LOGIN                = "/api/login.do"
    /// 로그아웃 요청 입니다.
    static let API_LOGOUT               = "/api/logout.do"
    /// 계좌 목록을 요청 합니다.
    static let API_ACCOUNTS             = "/api/v1/accounts"
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
    /// 현 세션이 활성화 상태인지를 체크 합니다.
    static let API_SESSION_CHECK        = "/api/checkLoginInfo"
    /// 만보기 약관 동의 요청 입니다.
    static let API_PEDO_TERMS_AGREE     = "/popup/insertPedometerTerms.do"
    /// QRCode 인증 할 제로페이 스크립트를 요청 합니다.
    static let API_ZEROPAY_QRCODE       = "/api/v1/zeropay/qrcode.do"
    /// NFT IMAGE 업로드 합니다.
    static let API_NFT_IMAGE            = "/api/uploadNftImg.do"
    /// 제로페이 간편결제 약관동의 체크 입니다.
    static let API_ZEROPAY_TERMS_CHECK  = "/api/v1/zeropay/qr/agree"
    /// 제로페이 간편결제 약관동의 입니다. ( POST 요청시 동의로 처리 합니다. )
    static let API_ZEROPAY_TERMS_AGREE  = "/api/v1/zeropay/qr/agree"
    /// 제로페이 간편결제 사용할 QRCode/BarCode 생성 할 정보 요청입니다.
    static let API_ZEROPAY_QR_BARCODE   = "/api/v1/zeropay/qr/code"
    /// 제로페이 간편결제 결제 금액 정보 숨김/보기 입니다.
    static let API_ZEROPAY_MONEY_ONOFF  = "/all/updateBalanceView.do"
    /// 제로페이 간편결제 (고정형)MPM 스캔한 QRCode 정상여부 체크 입니다.
    static let API_ZEROPAY_QRCODE_CHECK = "/api/v1/zeropay/qr/fixed"
    /// 제로페이 간편결제 메인화면 OK머니 잔액 조회 입니다.
    static let API_ZEROPAY_OkMONEY      = "/api/v1/okmoney"
}
