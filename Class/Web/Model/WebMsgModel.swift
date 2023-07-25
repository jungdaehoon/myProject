//
//  WebMsgModel.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/29.
//

import Foundation
import Combine


/**
 웹 인터페이스 헨들러들 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.28
 */
enum SCRIPT_MESSAGE_HANDLER_TYPE : String, CaseIterable {
    /// OKPay 기본 하이브리드 스크립트 입니다.
    case hybridscript                   = "hybridscript"
    /// 웹 쿠키 업데이트 입니다.
    case updateCookies                  = "updateCookies"
    /// GA 스크립트 용 입니다.
    case okpaygascriptCallbackHandler   = "okpaygascriptCallbackHandler"
}


/**
 웹 인터페이스 메세지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.28
 */
enum SCRIPT_MESSAGES : String
{
    /// 공유하기 입니다.
    case shareSNS                   = "shareSNS"
    /// 보안 키보드 오픈 입니다.
    case secureKeyShow              = "secureKeyShow"
    /// 문자보내기 요청 입니다.
    case sendSMS                    = "sendSMS"
    /// 현재 웹뷰를 캡쳐해서 사진(갤러리) 앱에 저장 합니다.
    case captureAndSaveImage        = "captureAndSaveImage"
    /// 사진(갤러리)앱에서 사진을 선택해서 서버에 전송 합니다.
    case getImageFromGallery        = "getImageFromGallery"
    /// 사진을 촬영해서 서버에 전송 합니다.
    case getImageFromCamera         = "getImageFromCamera"
    /// 로딩바 디스플레이 합니다.
    case showLoadingBar             = "showLoadingBar"
    /// 로딩바 히든 처리 합니다.
    case hideLoadingBar             = "hideLoadingBar"
    /// 신규 전체화면 웹뷰 오픈 입니다.
    case callHybridPopup            = "callHybridPopup"
    /// 현 페이지 종료후 이전 페이지 데이터 전송 팝업 형태 입니다.
    case confirmPopup               = "confirmPopup"
    /// 현 페이지 종료 입니다.
    case cancelPopup                = "cancelPopup"
    /// 현 페이지에서 파라미터 정보 가져오기 입니다. (페이지 진입시 받은 데이터 정보를 다시 넘기는 용도 인듯.... )
    case recieveParam               = "recieveParam"
    /// 웹 케시를 삭제 합니다.
    case clearCache                 = "clearCache"
    /// 신규 전체가 아닌 웹뷰 오픈 합니다.
    case showWebviewPopup           = "showWebviewPopup"
    /// 추가 웹 뷰어를 오픈 합니다. ( 이부분은 ;;;;; 디스플레이 해보고 판단해야 할듯 )
    case callHybridKindPopup        = "callHybridKindPopup"
    /// 레벨 안내 팝업 오픈 합니다.
    case showHybridLevelPopup       = "showHybridLevelPopup"
    /// 전체 화면 오픈뱅킹 안내 뷰어를 오픈 합니다.
    case showOpenBankAccAgreePopup  = "showOpenBankAccAgreePopup"
    /// 전체 화면 투자 타입 골드 팝업 입니다.
    case callHybridCenGoldPopup     = "callHybridCenGoldPopup"
    /// 오픈된 전체 화면 페이지 종료 입니다.  ( callHybridCenGoldPopup 페이지에서만 사용 하는듯... ㅠ.ㅜ 그만 만들어...같은거...)
    case closeHybridPopup           = "closeHybridPopup"
    /// 로그인 여부를 체크 합니다.
    case checkWebLogin              = "checkWebLogin"
    /// 현 웹뷰 받은 URL로 내부 웹페이지 디스플레이 합니다.
    case callDefaultBrowser         = "callDefaultBrowser"
    /// 내부 URL 연동이 아닌 받은 전체 URL 기준으로 화면 리로드 입니다.
    case launchExternalApp          = "launchExternalApp"
    /// 로그인 페이지를 디스플레이 합니다.
    case callLogin                  = "callLogin"
    /// 자동 로그인 설정 합니다.
    case autoLoginSetting           = "autoLoginSetting"
    /// 로그아웃 요청 입니다.
    case setLogout                  = "setLogout"
    /// 닉네임 정보를 받습니다.
    case setNickName                = "setNickName"
    /// 현 페이지를 종료하고 메인 홈으로 이동 합니다.
    case gotoHome                   = "gotoHome"
    /// 공용 토큰을 저장 합니다.
    case saveToken                  = "saveToken"
    /// 앱 내부 저장소에 데이터 저장 입니다.
    case setPreference              = "setPreference"
    /// 앱 내부 저장소에서 데이터를 추출 합니다.
    case getPreference              = "getPreference"
    /// 날짜 선택 피커뷰를 디스플레이 합니다.
    case getDatePicker              = "getDatePicker"
    /// GA 이벤트 정보를 넘깁니다.
    case sendGAEvent                = "sendGAEvent"
    /// 네이티브 기본 상단 인디게이터 ( 상태바 ) 높이 값을 요청 합니다.
    case getStatusBarHeight         = "getStatusBarHeight"
    /// 복사 요청 입니다. ( UIPasteboard 에 데이터 복사 합니다. )
    case copyPasteboard             = "copyPasteboard"
    /// 단말 OS 정보를 요청 합니다.
    case getOSType                  = "getOSType"
    /// 단말 디바이스명 요청 입니다.
    case getDeviceName              = "getDeviceName"
    /// APP Ver 요청 입니다.
    case getAppVersion              = "getAppVersion"
    /// PUSH 토큰 정보를 요청 합니다.
    case getPushToken               = "getPushToken"
    /// PUSH 인증 사용 여부 요청 입니다.
    case getPushSetting             = "getPushSetting"
    /// PUSH 설정 페이지 이동입니다.
    case movePushSetting            = "movePushSetting"
    /// 카카오톡 설치 여부 입니다.
    case installedKakaoTalk         = "installedKakaoTalk"
    /// 앱 업데이트 여부 체크 입니다.
    case appUpdate                  = "appUpdate"
    /// 만보고 이동 요청 입니다.
    case moveToManboGo              = "moveToManboGo"
    /// 현 웹페이지에 URL 정보를 받아 POST 타입으로 리로드 합니다.
    case callRedirectPostUrl        = "callRedirectPostUrl"
    /// URL 정보를 받아 외부 사파리 브라우저를 실행 합니다.
    case outSideOpenUrl             = "outSideOpenUrl"
    /// 년월 날짜 정보를 피커뷰로 하단에 디스플레이 합니다.
    case getSelectDate              = "getSelectDate"
    /// 연락처 검색을 요청 합니다.
    case getContactInfo             = "getContactInfo"
    /// 탭 인덱스 위치를 변경 합니다.
    case callTabChange              = "callTabChange"
    /// 제로페이에 리턴할 스크립트 콜백 정보를 받습니다.
    case callZeroPayCallBack        = "callZeroPayCallBack"
    /// 지갑 : 주소가져오기 : 존재유무 및 동일 확인 합니다.
    case getWAddress                = "getWAddress"
    /// 지갑 : 개인키가져오기 : 지갑에서 개인키를 획득후 전달 합니다.
    case checkWInfo                 = "checkWInfo"
    /// 지갑 : 생성후 정보 전달 : 지갑생성 후 주소:개인키 전달 합니다.
    case createWInfo                = "createWInfo"
    /// 지갑 : 복구 : 니모닉을 받아 지갑을 복구 하고 주소 전달 합니다.
    case restoreWInfo               = "restoreWInfo"
    /// 지갑 : 복구구문 보기 : 니모닉 정보를 화면에 표시 합니다.
    case showWRestoreText           = "showWRestoreText"
    /// 지갑 : QR주소 읽기 : QR코드에서 주소를 읽어 전달 합니다.
    case readQRInfo                 = "readQRInfo"
    /// 지갑 : 카카오 채널 연결: 대화를 위해 카카오 채널을 호출 합니다.
    case queryWKakao                = "queryWKakao"
    /// 계좌 목록 팝업 오픈 요청 입니다.
    case accoutsPopup               = "accoutsPopup"
    /// 제로페이 약관동의 팝업 오픈 이벤트 입니다.
    case openZeropayQRAgreement     = "openZeropayQRAgreement"
    /// 제로페이 하단 이동 안내 팝업 오픈 입니다.
    case openZeropayQRIntro         = "openZeropayQRIntro"
}



/**
 웹 헨들러 지원 모델 입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.20
*/
class WebMsgModel : BaseViewModel {
    
    /**
      NFI 이미지를  전송 합니다. ( J.D.H VER : 1.0.0 )
     - Description: NFT 등록시 이미지 업로드 용으로 사용 합니다.
     - Date: 2023.06.23
     - Parameters:
        - image : 서버에 업로드할 이미지 입니다.
     - Throws: False
     - Returns:
        웹페이지로  리턴할 스크립트를 리턴 합니다.  Future<String?, Never>
     */
    func setUpdateImage( image : UIImage ) -> Future<String?, Never>
    {
        return Future<String?, Never> { promise in
            /// 서버에 이미지를 전송 합니다.
            self.request(image: image, url: APIConstant.API_NFT_IMAGE).sink { value in
                /// NFT 업로드 결과용 스크립트 데이터를 기본 정보로 설정 합니다.
                var retJsonStr = self.getNftReturnJsonMsg()
                if let value = value,
                   let data  = value["data"] as? [String:Any],
                   let url   = data["url"] as? String
                {
                    let infoStr = data["info"] as? String ?? ""
                    /// NFT 업로드 결과용 스크립트를 가져 옵니다.
                    retJsonStr  = self.getNftReturnJsonMsg(url,infoStr)
                }
                promise(.success(retJsonStr))
            }.store(in: &self.cancellableSet)
        }
    }
    
    
    /**
     Wallet 스크립트 Message 데이터를 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.24
     - Throws: False
     - Parameters :
        - retStr : 리턴 할 데이터 정보 입니다.
     - Returns:
        리턴 할 데이터 정보 입니다. (Future<String, Never>)
     */
    func getWalletJsonMsg( retStr: String? ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            var retJsonStr = ""
            if let ret = retStr, ret.isValid {
                retJsonStr = self.getWalletJsonString (true,data: retStr ?? "", msg: "")
            }
            else
            {
                retJsonStr = self.getWalletJsonString (false,data: "", msg: "No wallet info")
            }
            promise(.success(retJsonStr))
        }
    }
    
    
    /**
     Wallet 리턴 데이터를 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.24
     - Throws: False
     - Parameters :
        - isSuccess : 데이터 여부 입니다.
        - data : 데이터 정보 입니다.
        - msg : 데이터가 없는 경우 메세지 정보 입니다.
     - Returns:
        리턴 할 데이터 정보 입니다. (Future<String, Never>)
     */
    private func getWalletJsonString(_ isSuccess: Bool , data: String, msg: String) -> String {
        let resultStr   : String        = isSuccess ? "true" :  "false"
        let dataStr     : String        = isSuccess ? data :  ""
        let errorStr    : String        = isSuccess ? "" :  msg
        /// 총 데이터 메세지 입니다.
        let message     : [String:Any]  = [ "result" : resultStr,
                                            "data" : dataStr,
                                            "msg" : errorStr]
        do {
            let data =  try JSONSerialization.data(withJSONObject: message, options:.prettyPrinted)
            if let dataString = String.init(data: data, encoding: .utf8) {
                return dataString
            }
        } catch {
            return ""
        }
        return ""
    }

    /**
     NFT 이미지 업로드 결과를 JSon 형태로 웹 스크립트 Message 를 생성 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.06.23
     - Throws: False
     - Parameters :
        - isSuccess : 데이터 여부 입니다.
        - data : 데이터 정보 입니다.
        - msg : 데이터가 없는 경우 메세지 정보 입니다.
     - Returns:
        리턴 할 데이터 정보 입니다. (Future<String, Never>)
     */
    private func getNftReturnJsonMsg( _ url:String = "", _ infoStr:String = "" ) -> String {
        var isSuccess = false
        if (url.count > 0 ){
            isSuccess = true
        }

        let resultStr : String = isSuccess ? "true" :  "false"
        let errorStr  : String = isSuccess ? "" :  "파일 업로드 오류 입니다."
        
        // 앱버전 조회
        let message : [String:Any] = [
            "result" : resultStr,
            "url" : url,
            "info" : infoStr,
            "msg" : errorStr,
        ]
        
        do {
            let data =  try JSONSerialization.data(withJSONObject: message, options:.prettyPrinted)
            if let dataString = String.init(data: data, encoding: .utf8) {
                //resultCallback( HybridResult.success(message: dataString ))
                return dataString
            }
        } catch {
           // resultCallback( HybridResult.success(message: dataString ))
            return ""
        }
        return ""
    }
    
}
