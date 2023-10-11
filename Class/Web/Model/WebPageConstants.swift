//
//  WebPageConstants.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import Foundation


/**
 웹 화면 연결 URL 정보입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.23
*/
class WebPageConstants {
    /// 도메인 URL 정보를 가져 옵니다.
    static let baseURL                          = Bundle.main.infoDictionary?["HOST_SERVER_URL"] as? String ?? ""
    /// 메인 페이지 입니다.
    static let URL_MAIN                         = baseURL + "/main.do"
    /// 휴먼 회원 페이지 입니다.
    static let URL_WAKE_SLEEP_USER              = baseURL + "/mem/wakeSleepUser.do"
    /// 보안키패드 연결할시 보안키패드 sessionId, token 받는 URL 정보 입니다.
    static let URL_KEYBOARD_E2E                 = baseURL + "/xkservice"
    /// 오픈뱅킹일때, 은행계좌 연결하기 페이지로 약관동의 부터 시작 합니다.
    static let URL_OPENBANK_ACCOUNT_REGISTER    = baseURL + "/mem/memJoinMain.do?joinType=openbank&openbankRegister=true"
    /// 은행계좌 연결 페이지 입니다.
    static let URL_ACCOUNT_REGISTER             = baseURL + "/myp/mypAccountRegPage.do"
    /// 송금 보내기 페이지 입니다.
    static let URL_REMITTANCE_MONEY             = baseURL + "/myp/mypRemittance.do"
    /// 금융 페이지 입니다.
    static let URL_FINANCE_MAIN                 = baseURL + "/finance/financeMain.do"
    /// 혜택 페이지 입니다.
    static let URL_BENEFIT_MAIN                 = baseURL + "/all/benefitList.do"
    /// OK 머니 페이지 입니다.
    static let URL_ACCOUNT_TRANSFER_LIST        = baseURL + "/myp/mypAccountTransList.do"
    /// OK 머니 충전 페이지 입니다.
    static let URL_RECHARE_MONEY                = baseURL + "/myp/mypRecharge.do"
    /// OK 포인트 페이지 입니다.
    static let URL_POINT_TRANSFER_LIST          = baseURL + "/myp/mypPointTransHistory.do"
    /// 결제 페이지 입니다.
    static let URL_TOTAL_PAY_LIST               = baseURL + "/all/totalPaymentList.do"    
    /// 카카오톡 문의하기 페이지 입니다.
    static let URL_KAKAO_CONTACT                = "https://pf.kakao.com/_hxcrZG"
    /// 올림pick 페이지 입니다.
    static let URL_OLIMPICK_LIST                = baseURL + "/community/communityQuiz.do"
    /// 계좌 재인증 페이지 입니다.
    static let URL_TOKEN_REISSUE                = baseURL + "/openbank/tokenReissue.do"
    /// 연결된 계좌 리스트 페이지 입니다.
    static let URL_MY_ACCOUNT_LIST              = baseURL + "/myp/mypAccountList.do"
    /// 뿌리Go 페이지 입니다.
    static let URL_MY_RELATIONSHIP              = baseURL + "/myp/mypRelationship.do"
    /// 닉네임 화면 입니다.
    static let URL_CHANGE_NICKNAME              = baseURL + "/all/changeNickname.do?type=login"
    /// 만보기 서비스 이용안내/개인 정보제공 동의 페이지 입니다. ( ?terms_cd=S001 / ?terms_cd=S002 )
    static let URL_PEDO_TERMS                   = baseURL + "/popup/pedometerTermsView.do"
    /// 재로페이 상품권으로 결제 인증 요청 입니다.
    static let URL_ZERO_PAY_GIFTCARD_PAYMENT    = baseURL + "/zeropay/giftcard/payment.do"
    /// 재로페이 상품권 구매웹뷰 입니다.
    static let URL_ZERO_PAY_PURCHASE            = baseURL + "/zeropay/giftcard/purchase.do"
    /// 재로페이 상품권 환불웹뷰 입니다.
    static let URL_ZERO_PAY_PURCHASE_CANCEL     = baseURL + "/zeropay/giftcard/purchase/cancel.do"
    /// 재로페이 간편결제 약관동의 페이지 입니다.
    static let URL_ZERO_PAY_AGREEMENT           = baseURL + "/popup/pedometerTermsView.do"
    /// 재로페이 간편결제 QRCode/BarCode 사용요청 전 거래 인증 체크용 키패드 웹뷰 입니다.
    static let URL_ZERO_PAY_QR_KEYPAD_SHOW      = baseURL + "/zeropay/qr/barcode"
    /// 재로페이 간편결제 QRCode 스캔 결제 요청 입니다.
    static let URL_ZERO_PAY_QR_OKMONEY_PAYMENT  = baseURL + "/zeropay/qr/payment"
    /// 월렛 홈 페이지 입니다.
    static let URL_WALLET_HOME                  = baseURL + "/walletHome.do"
    /// NFT 받는 페이지 입니다.
    static let URL_MYP_RECEIVE                  = baseURL + "/nft/transfer/transferNftAccept.do"
    /// NFT 보유 목록 페이지 입니다.
    static let URL_NFT_OWN_LIST                 = baseURL + "/nft/own/ownNftList.do"
    /// NFT 거래내역 페이지 입니다.
    static let URL_NFT_TRANS_LIST               = baseURL + "/nft/own/ownNftTransList.do"
    /// NFT 발행내역 페이지 입니다.
    static let URL_NFT_ISSUED_LIST              = baseURL + "/nft/own/ownNftIssuedList.do"
    /// NFT 수집 목록 페이지 입니다.
    static let URL_NFT_COLLECTED_LIST           = baseURL + "/nft/own/ownNftCollectedList.do"
    /// 마켓 구매내역 페이지 입니다.
    static let URL_MARKET_HISTORY               = baseURL + "/myp/mypGifticonList.do?tab=myTab"
        
    
    /**
     도메인 체크하여 URL 정보에 도메인을 추가하여 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.08.28
     - Parameters:
        - url : 체크 할 URL 정보 입니다.
     - Returns:False
     */
    static func getDomainURL( _ url : String ) -> String {
        if url.contains("https") ||
           url.contains("http")
        {
            return url
        }
        return WebPageConstants.baseURL + url
    }
}
