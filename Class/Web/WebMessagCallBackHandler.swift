//
//  WebMessagCallBackHandler.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import Foundation
import WebKit
import MessageUI
import Combine
import Firebase
import FirebaseMessaging
import MobileCoreServices
import ContactsUI
import AddressBook
import AddressBookUI

/**
 WebMessagCallBackHandler 에서 지원하지 않는 message handler 를 등록하여 처리합니다.
1. 생성자 호출(init(webView: WKWebView), init(baseView: BaseWebViewController)
2. addHandler 로 등록
 */
@objc protocol CustomScriptMessageInterfaceDelegate {
    
    func addScriptHandler()
    /// return 이 true이면 CustomScriptMessageInterface에서 이미 처리한 message 입니다.
    func didReceive(message: WKScriptMessage)
    /// 등록된  message handelr를 모두삭제 합니다.
    @objc optional func removeAll()
}



/**
 웹 인터페이스 컨트롤 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.28
 */
class WebMessagCallBackHandler : NSObject  {
    private var curCancellable: AnyCancellable?
    var cancellableSet = Set<AnyCancellable>()
    var viewModel           : WebMsgModel = WebMsgModel()
    /// 웹 페이지 입니다.
    var webView             : WKWebView?
    /// 웹뷰 연결 설정 정보를 가집니다.
    let config              : WKWebViewConfiguration = WKWebViewConfiguration()
    /// 연결된 컨트롤로 뷰어 입니다.
    var target              : UIViewController?
    /// 리턴 델리게이트 입니다.
    private var delegate    : CustomScriptMessageInterfaceDelegate?
    
    
    // MARK: - init
    /**
     웹 인터페이스 헨들러 초기화를 진행 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:
        - webViewController : 연결 컨트롤 뷰어 입니다.
        - completion : 연결된 configuration 을 리턴 합니다.
     - Throws : False
     - returns :False
     */
    init( webViewController : BaseWebViewController ) {            
    }

    
    /** 
     웹 인터페이스 헨들러 정보를 받아 타입별 분기 처리 합니다.
     - Description : hybridscript WebAPP 인터페이스 정보를 받아 처리 합니다.
     - Date : 2023.03.28
     - Parameters:
        - message : 스크립트 메세지 정보를 받습니다.
     - Throws : False
     - returns :False
     */
    func didReceiveMessage(message: WKScriptMessage) {
        /// 메세지 데이터 입니다.
        if let body = message.body as? [Any?] ,
           body.count == 3 {
            let scriptName = body[1] as! String
            switch SCRIPT_MESSAGES(rawValue: scriptName) {
                /// 공유하기 입니다.
            case .shareSNS                   :
                self.setShareApp( body )
                break
                /// 보안 키보드 오픈 입니다.
            case .secureKeyShow              :
                self.setSecureKeyPadDisplay( body )
                break
                /// 문자보내기 요청 입니다.
            case .sendSMS                    :
                self.setSendSMS( body )
                break
                /// 현재 웹뷰를 캡쳐해서 사진(갤러리) 앱에 저장 합니다.
            case .captureAndSaveImage        :
                self.setWebViewCapture( body )
                break
                /// 사진(갤러리)앱에서 사진을 선택해서 프로필 사진으로 서버에 전송 합니다.
            case .getImageFromGallery        : break
                /// 로딩바 디스플레이 합니다.
            case .showLoadingBar             :
                LoadingView.default.show()
                break
                /// 로딩바 히든 처리 합니다.
            case .hideLoadingBar             :
                LoadingView.default.hide()
                break
                /// 신규 전체화면 웹뷰 오픈 입니다.
            case .callHybridPopup            :
                self.setWebViewDisplay( body )
                break
                /// 현 페이지 종료후 이전 페이지 데이터 전송 팝업 형태 입니다.
            case .confirmPopup               :
                self.setConfirmPopup( body )
                break
                /// 현 페이지 종료 입니다.
            case .cancelPopup                :
                self.setTargetDismiss()
                break
                /// 현 페이지에서 파라미터 정보 가져오기 입니다. (페이지 진입시 받은 데이터 정보를 다시 넘기는 용도 인듯.... )
            case .recieveParam               :
                self.setRecieveParamToWeb( body )
                break
                /// 웹 케시를 삭제 합니다.
            case .clearCache                 :
                self.setWebViewClearCache()
                break
                /// 신규 전체가 아닌 웹뷰 오픈 합니다.
            case .showWebviewPopup           :
                self.setWebViewDisplay( body, fullDisplay: false )
                break
                /// 추가 웹 뷰어를 오픈 합니다. ( 이부분은 ;;;;; 디스플레이 해보고 판단해야 할듯 )
            case .callHybridKindPopup        : break
                /// 레벨 안내 팝업 오픈 합니다.
            case .showHybridLevelPopup       :
                self.setLevelPop( body )
                break
                /// 전체 화면 오픈뱅킹 안내 뷰어를 오픈 합니다.
            case .showOpenBankAccAgreePopup  :
                self.setHybridOpenBank( body )
                break
                /// 전체 화면 투자 타입 골드 팝업 입니다. ( 투자는 이번 버전에서 제외 되는듯 )
            case .callHybridCenGoldPopup     : break
                /// 오픈된 전체 화면 페이지 종료 입니다.  ( callHybridCenGoldPopup 페이지에서만 사용 하는듯... ㅠ.ㅜ 그만 만들어...같은거...)
            case .closeHybridPopup           :
                self.setTargetDismiss()
                break
                /// 로그인 여부를 체크 합니다.
            case .checkWebLogin              : break
                /// 현 웹뷰 받은 URL로 내부 웹페이지 디스플레이 합니다.
            case .callDefaultBrowser         : break
                /// 내부 URL 연동이 아닌 받은 전체 URL 기준으로 화면 리로드 입니다.
            case .launchExternalApp          : break
            /// 로그인 페이지를 디스플레이 합니다.
            case .callLogin                  :
                self.setLoginDisplay()
                break
            /// 자동 로그인 설정 합니다.
            case .autoLoginSetting           :
                self.setAutoLoginSetting( body )
                break
            /// 로그아웃 요청 입니다.
            case .setLogout                  :
                self.setLogOut( body )
                break
            /// 공용 토큰을 저장 합니다.
            case .saveToken                  :
                self.setSaveToken( body )
                break
            /// 앱 내부 저장소에 데이터 저장 입니다.
            case .setPreference              :
                self.setPreference( body )
                break
            /// 앱 내부 저장소에서 데이터를 추출 합니다.
            case .getPreference              :
                self.getPreference( body )
                break
            /// 날짜 선택 피커뷰를 디스플레이 합니다.
            case .getDatePicker              :
                self.setDatePickerView( body )
                break
            /// GA 이벤트 정보를 넘깁니다.
            case .sendGAEvent                : break
            /// 네이티브 기본 상단 인디게이터 ( 상태바 ) 높이 값을 요청 합니다.
            case .getStatusBarHeight         : break
            /// 복사 요청 입니다. ( UIPasteboard 에 데이터 복사 합니다. )
            case .copyPasteboard             :
                self.setPasteboard( body )
                break
            /// 단말 OS 정보를 요청 합니다.
            case .getOSType                  :
                self.getOSType( body )
                break
            /// 단말 디바이스명 요청 입니다.
            case .getDeviceName              :
                self.getDevice( body )
                break
            /// APP Ver 요청 입니다.
            case .getAppVersion              :
                self.getAppVer( body )
                break
            /// PUSH 토큰 정보를 요청 합니다.
            case .getPushToken               :
                self.getPushToken( body )
                break
            /// PUSH 인증 사용 여부 요청 입니다.
            case .getPushSetting             :
                self.getPushAuth( body )
                break
            /// PUSH 설정 페이지 이동입니다.
            case .movePushSetting            :
                self.setMoveDeviceSetting()
                break
            /// 카카오톡 설치 여부 입니다.
            case .installedKakaoTalk         :
                self.setIstalledKakaoTalk( body )
                break
            /// 앱 업데이트 여부 체크 입니다.
            case .appUpdate                  :
                self.setAppUpdate()
                break
            /// 만보고 이동 요청 입니다.
            case .moveToManboGo              :
                self.setMoveToManboGo()
                break
            /// 현 웹페이지에 URL 정보를 받아 POST 타입으로 리로드 합니다.
            case .callRedirectPostUrl        :
                self.setCallRedirectPostUrl( body )
                break
            /// URL 정보를 받아 외부 사파리 브라우저를 실행 합니다.
            case .outSideOpenUrl             :
                self.setOutSideOpenUrl( body )
                break
            /// 년월 날짜 정보를 피커뷰로 하단에 디스플레이 합니다.
            case .getSelectDate              :
                self.setDateDisplay( body )
                break
            /// 연락처 검색을 요청 합니다.
            case .getContactInfo            :
                self.setContactInfo( body )
                break
            /// 탭 인덱스 위치를 변경 합니다.
            case .callTabChange             :
                self.setTabChange( body )
                break
            case .callZeroPayCallBack       :
                self.setZeroPayCB ( body )
                break
                /// 지갑 : 주소가져오기 : 존재유무 및 동일 확인 합니다.
            case .getWAddress                :
                self.setWAddressWalletFile( body )
                break
                /// 지갑 : 개인키가져오기 : 지갑에서 개인키를 획득후 전달 합니다.
            case .checkWInfo                 :
                self.setPrivateKeyWithWalletFile( body )
                break
                /// 지갑 : 생성후 정보 전달 : 지갑생성 후 주소:개인키 전달 합니다.
            case .createWInfo                :
                self.setCreateWallet( body )
                break
                /// 지갑 : 복구 : 니모닉을 받아 지갑을 복구 하고 주소 전달 합니다.
            case .restoreWInfo               :
                self.setRestoreWInfo( body )
                break
                /// 지갑 : 복구구문 보기 : 니모닉 정보를 화면에 표시 합니다.
            case .showWRestoreText           :
                self.setMnemonicDisplay( body )
                break
                /// 지갑 : QR주소 읽기 : QR코드에서 주소를 읽어 전달 합니다.
            case .readQRInfo                 :
                self.setQRCodeReadDisplay( body )
                break
                /// 지갑 : 카카오 채널 연결: 대화를 위해 카카오 채널을 호출
            case .queryWKakao                :break
            default: break
            }
        }
    }
    
    
    func setQRCodeReadDisplay( _ body : [Any?] )
    {
        let mainStoryboard  = UIStoryboard(name: "Wallet", bundle: nil)
        let vc              = mainStoryboard.instantiateViewController(withIdentifier: "QRReaderViewController") as? QRReaderViewController
        //vc!.delegate         = self
        self.target!.navigationController!.pushViewController(vc!, animated: true, animatedType :.up)
    }
        
        
    func setMnemonicDisplay( _ body : [Any?] )
    {
        /// 파라미터 정보가 있는 경우 입니다.
        if let _   = body[2] as? [Any]
        {
            let mainStoryboard  = UIStoryboard(name: "Wallet", bundle: nil)
            let vc              = mainStoryboard.instantiateViewController(withIdentifier: "ShowMnemonicViewController") as? ShowMnemonicViewController
            vc!.showNext         = true
            //vc!.delegate         = self
            self.target!.navigationController!.pushViewController(vc!, animated: true, animatedType :.up)
        }
    }
    
    func setRestoreWInfo( _ body : [Any?] ){
        
        /// 파라미터 정보가 있는 경우 입니다.
        if let params   = body[2] as? [Any]
        {
            let encInfo         = params[0] as! String
            let preAddr         = params.count > 1 ? NC.S(params[1] as? String) : ""
            
            let mainStoryboard  = UIStoryboard(name: "Wallet", bundle: nil)
            let vc              = mainStoryboard.instantiateViewController(withIdentifier: "RestoreWalletViewController") as? RestoreWalletViewController
            vc!.encInfo         = encInfo
            vc!.preAddr         = preAddr
            //vc!.delegate        = self
            self.target!.navigationController!.pushViewController(vc!, animated: true, animatedType :.up)
        }
    }
    
    
    func setCreateWallet( _ body : [Any?] ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks   = body[0] as! [Any]
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let action      = body[1] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params   = body[2] as? [Any]
        {
            let encInfo = params[0] as! String
            print ("psg test:checkw  encInfo = \(encInfo) " )
            let wRet = WalletHelper.sharedInstance.createWallet(self.target!, encInfo: encInfo)
            print ("psg test:checkw  wRet = \(wRet ?? "nil") " )
            var encWaddr = ""
            if let tRet = wRet  {
                encWaddr = WalletHelper.sharedInstance.makeEncryptString(orgStr: tRet)
            }
            /// 콜백 데이터 정보를 요청 합니다.
            self.viewModel.getWalletJsonMsg(retStr: encWaddr).sink { message in
                /// 콜백으로 데이터를 리턴 합니다.
                self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: message)
            }.store(in: &self.viewModel.cancellableSet)
        }
    }
    
    
    func setPrivateKeyWithWalletFile( _ body : [Any?] ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks   = body[0] as! [Any]
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let action      = body[1] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params   = body[2] as? [Any]
        {
            let encInfo = params[0] as! String
            print ("psg test:checkw  encInfo = \(encInfo) " )
            let wRet = WalletHelper.sharedInstance.checkPrivateKeyWithWalletFile(self.target!, encInfo: encInfo)
            print ("psg test:checkw  wRet = \(wRet ?? "nil") " )
            var encWaddr = ""
            if let tRet = wRet  {
                encWaddr = WalletHelper.sharedInstance.makeEncryptString(orgStr: tRet)
            }
            
            /// 콜백 데이터 정보를 요청 합니다.
            self.viewModel.getWalletJsonMsg(retStr: encWaddr).sink { message in
                /// 콜백으로 데이터를 리턴 합니다.
                self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: message)
            }.store(in: &self.viewModel.cancellableSet)
        }
    }
    
    
    func setWAddressWalletFile( _ body : [Any?] ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks   = body[0] as! [Any]
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let action      = body[1] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params   = body[2] as? [Any]
        {
            let encInfo = params[0] as! String
            print ("psg test:getw  encInfo = \(encInfo) " )
            let wRet = WalletHelper.sharedInstance.checkWAddressWalletFile(self.target!, encInfo: encInfo)
            print ("psg test:getw  wRet = \(wRet ?? "nil") " )
            var encWaddr = ""
            if let tRet = wRet  {
                encWaddr = WalletHelper.sharedInstance.makeEncryptString(orgStr: tRet)
            }
            
            /// 콜백 데이터 정보를 요청 합니다.
            self.viewModel.getWalletJsonMsg(retStr: encWaddr).sink { message in
                /// 콜백으로 데이터를 리턴 합니다.
                self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: message)
            }.store(in: &self.viewModel.cancellableSet)
        }
    }
    
    
    /**
     제로페이에 리턴할 콜백 스크립트를 받습니다.
     - Date : 2023.04.19
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setZeroPayCB( _ body : [Any?] ){
        let params          = body[2] as! [Any]
        if let info = params[0] as? [String:String]
        {
            /// 인덱스 정보를 받아 탭 인덱스를 변경 합니다.
            if let callType = info["callType"]
            {
                switch callType
                {
                    /// 상품권 사용시 사용자 인증 콜백 입니다.
                case "UA":
                    self.setTargetDismiss( NC.S(info["callback"]) )
                    break
                    /// 삼품권 구매,환불 진행시 인증 콜백 입니다.
                case "TA":
                    self.setTargetDismiss( NC.S(info["callback"]) )
                    break
                default:break
                }
            }
        }
    }
    
    
    /**
     하단 탭 인덱스 정보를 받아 탭 페이지를 변경 합니다.
     - Date : 2023.04.18
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setTabChange( _ body : [Any?] ){
        let params          = body[2] as! [Any]
        if let info = params[0] as? [String:String]
        {
            /// 인덱스 정보를 받아 탭 인덱스를 변경 합니다.
            if let tabIndex = info["tabIndex"] {
                TabBarView.tabbar!.selectedIndex = Int(tabIndex)!
            }
        }
    }
    
    
    /// 추가할 연락처 정보를 받습니다.
    @Published var contactInfo : [String] = []
    /**
     연락처 정보를 조회해 리턴 합니다.
     - Date : 2023.04.17
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setContactInfo( _ body : [Any?] )
    {
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks = body[0] as! [Any]
        self.viewModel.isContactAuthorization().sink { success in
            if success
            {
                /// 추가 할 연락처를 받아 콜백으로 리턴 합니다.
                self.$contactInfo.sink { contactInfo in
                    /// 추가된 정보가 있는 경우에만 업로드 합니다.
                    if contactInfo.count > 0
                    {
                        self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: contactInfo)
                        self.contactInfo.removeAll()
                    }                    
                }.store(in: &self.cancellableSet)
                
                /// 연락쳐 디스플레이 뷰어를 호출 합니다.
                let picker                          = CNContactPickerViewController()
                picker.delegate                     = self
                picker.displayedPropertyKeys        = [CNContactPhoneNumbersKey]
                // 폰 넘버가 0 개 이상만 선택가능하도록, 0 개 이면 선택 불가
                picker.predicateForEnablingContact  = NSPredicate(format: "phoneNumbers.@count > 0 ")
                self.target!.present(picker, animated:true)
            }
        }.store(in: &self.viewModel.cancellableSet)        
    }
    
    
    /**
     자동로그인 타입을 변경 합니다.
     - Date : 2023.04.12
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setAutoLoginSetting( _ body : [Any?] ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks = body[0] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params = body[2] as? [Any]
        {
            if let loginType = params[0] as? String
            {
                if let custItem = SharedDefaults.getKeyChainCustItem()
                {
                    if loginType == "Y"
                    {
                        custItem.auto_login = true
                        self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: "Y")
                    }
                    else
                    {
                        custItem.auto_login = false
                        self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: "N")
                    }
                    SharedDefaults.setKeyChainCustItem(custItem)
                }
            }
        }
    }
    
    
    /**
     로그인 여부를 체크 합니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func checkWebLogin()
    {
        if let _ = BaseViewModel.loginResponse
        {
            BaseViewModel.loginResponse?.islogin = true
        }
    }
    
    
    /**
     전체 화면 웹뷰를 디스플레이 합니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setDateDisplay( _ body : [Any?] ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks = body[0] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params = body[2] as? [Any]
        {
            if let info = params[0] as? [String : String]
            {
                let minDate     = NC.S(info["minDate"])
                let maxDate     = NC.S(info["maxDate"])
                let selectDate  = NC.S(info["selectDate"])
                let dateType    = NC.S(info["dateType"])

                DatePickerView().setDisplayView(DATE_TYPE(rawValue: dateType) ?? .all_date, selectDate: selectDate, maxDate: maxDate, minDate: minDate) { value in
                    let formatter : DateFormatter   =  DateFormatter()
                    formatter.dateFormat            = "yyyyMMdd"
                    let dateText                    = formatter.string(from: value )
                    self.setEvaluateJavaScript(callback: callBacks[0] as! String , message: dateText)
                }
                
                //self.target!.view.addSubview(dateView!)
            }
        }
    }
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     전체 화면 웹뷰를 디스플레이 합니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
        - fullDisplay : 전체 화면 모드 입니다.
     - Throws : False
     - returns :False
     */
    func setWebViewDisplay( _ body : [Any?], fullDisplay : Bool = true ){
        /// 전체 팝업 종료시 리턴할 콜백 메서드들 입니다.
        let callBacks = body[0] as! [Any]
        /// 파라미터 정보가 있는 경우 입니다.
        if let params = body[2] as? [Any]
        {
            /// 연결할 URL 정보를 받습니다.
            let url         = params[0] as! String
            if let info     = Utils.toJSON(params[1] as! String)
            {
                /// 페이지 타입을 받습니다.
                if let type    = info["type"] as? String
                {
                    let pageType = FULL_PAGE_TYPE(rawValue: type) ?? .default_type
                    switch pageType {
                        /// PG 카드 결제 요청 입니다.
                    case .pg_type,.zeropay_type,.auth_type:
                        /// 상단 타이틀 디스플레이 여부 입니다.
                        let title           = NC.S(info["title"] as? String)
                        /// 상단 타이틀 디스플레이 여부 입니다. ( 0 : 타이틀 바 히든, 1 : 뒤로가기 버튼, 2 : 종료 버튼 )
                        let button          = NC.S( info["button"] as? String )
                        /// PG 결제에서 사용할 콜백 메서드 입니다.
                        let pg_Callback     = callBacks[0] as! String
                        let linkUrl         = AlamofireAgent.domainUrl + url
                        /// 전체 화면 웹뷰를 오픈 합니다.
                        let viewController  = FullWebViewController.init(pageType: FULL_PAGE_TYPE(rawValue: type) ?? .default_type, title: title, titleBarHidden: button == "0" ? true : false, pageURL: linkUrl) { cbType in
                            
                            switch cbType {
                            case .pageClose :
                                break
                            case .loginCall :
                                self.setLoginDisplay()
                            case .scriptCall( let callback , let message, _ ) :
                                self.setEvaluateJavaScript(callback: callback == "" ? pg_Callback : callback, message: message, isJson: true)
                            default:break
                            }
                        }
                        
                        /// 전체 화면 모드 입니다.
                        if fullDisplay == true
                        {
                            if let controller = self.target
                            {
                                if let navigation = controller.navigationController
                                {
                                    navigation.pushViewController(viewController, animated: true, animatedType: .up)
                                }
                                else
                                {
                                    controller.present(viewController,animated: true)
                                }
                            }
                        }
                        else
                        {
                            if let controller = self.target
                            {
                                controller.present(viewController,animated: true)
                            }
                        }
                        return
                        /// 약관동의 페이지 요청 입니다.
                    case .db_type:
                        /// 전체 화면 웹뷰를 오픈 합니다.
                        let viewController = FullWebViewController.init( titleBarHidden: true, pageURL: AlamofireAgent.domainUrl +  url) { cbType in
                            switch cbType {
                            case .pageClose:
                                return
                            case .scriptCall( let collBackID, _, let controller ):
                                controller.messageHandler!.setEvaluateJavaScript(callback: collBackID, message: params[1], isJson: true)
                                return
                            default:
                                break
                            }
                        }
                        
                        if let controller = self.target
                        {
                            controller.present(viewController,animated: true)
                        }
                        return
                    
                    default:
                        break
                    }
                    
                    /// 전체 화면 웹뷰를 오픈 합니다.
                    let viewController  = FullWebViewController.init( pageURL: AlamofireAgent.domainUrl +  url) { cbType in
                    }
                    self.target!.navigationController?.pushViewController(viewController, animated: true, animatedType: .up)
                    return
                }
                
                /// 전체 화면 웹뷰를 오픈 합니다.
                let viewController  = FullWebViewController.init( pageURL: AlamofireAgent.domainUrl +  url) { cbType in
                }
                self.target!.navigationController?.pushViewController(viewController, animated: true, animatedType: .up)
            }
        }
    }
    
    
    /**
     페이지 종료후 이전 웹뷰에 데이터를 넘깁니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setConfirmPopup( _ body : [Any?] ){
        var object : String?
        
        if let params = body[2] as? [Any]
        {
            if let info = params[0] as? [String:Any]
            {
                /// 페이지 종료시 리턴할 타입 정보를 받습니다.
                let type    = NC.S( info["type"] as? String )
                switch type
                {
                    /// PG 결제 요청을 리턴 합니다.
                case "PG":
                    /// 결제 정보를 받습니다.
                    do {
                        /// 결제 정보를 문자 형태로 변환하여 리턴 합니다.
                        if let message = try Utils.toJSONString(info)
                        {
                            self.setTargetDismiss( param: message )
                        }
                    } catch { }
                    return
                default:break;
                }
                                
                /// 데이터 문자 타입 여부를 체크 합니다.
                if let jsonArg = info["param"] as? String
                {
                    object = jsonArg
                }
                /// 데이터 Dic 타입 여부를 체크 합니다.
                else if let jsonArg = info["param"] as? [String:Any]
                {
                    do {
                        /// 결제 정보를 문자 형태로 변환하여 리턴 합니다.
                        if let message = try Utils.toJSONString(jsonArg)
                        {
                            object = message
                        }
                    } catch { }
                }
                /// 데이터가 없을경우 기본 정보를 설정 합니다.
                else
                {
                    do {
                        /// 결제 정보를 문자 형태로 변환하여 리턴 합니다.
                        if let message = try Utils.toJSONString(["dummy1":"value1"])
                        {
                            object = message
                        }
                    } catch { }
                }
            }
        }
        
        /// 페이지 종료처리 합니다.
        self.setTargetDismiss( param: NC.S(object) )
    }
    
    
    /**
     이전에 웹 호출시에 받은 데이터를 다시 현 웹에게 전송합니다.
     - Date : 2023.03.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setRecieveParamToWeb( _ body : [Any?] ){
        let callback        = body[0] as! [Any?]
        if let controller = self.target as? FullWebViewController
        {
            controller.completion!(.scriptCall(collBackID: callback[0] as! String , message: "", controller: controller))
        }
    }
    
    
    /**
     로그인 페이지를 디스플레이 합니다.
     - Date : 2023.03.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setLoginDisplay(){
        /// 현 페이지가 전체 웹뷰라면 이전 페이지가 로그인 페이지로 체크 하여 페이지를 종료 합니다. 웹뷰 타입 경우인지를 체크 합니다.
        if let controller = self.target as? FullWebViewController
        {
            /// 로그인 페이지 요청 입니다.
            controller.completion!(.loginCall)
            controller.navigationController?.popViewController(animated: true, completion: {
            })
            return
        }
        
        /// 로그인 페이지를 디스플레이 합니다.
        let viewController                      = LoginViewController()
        viewController.modalPresentationStyle   = .overFullScreen
        self.target!.navigationController?.pushViewController( viewController, animated: true, animatedType: .up)
    }
    
    
    /**
     웹뷰 캐시를 삭제 합니다.
     - Date : 2023.03.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setWebViewClearCache() {
        let websiteDataTypes    = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date                = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }
    
    
    /**
     문자 외부 공유 입니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 바디 데이터 입니다.
     - Throws : False
     - returns :False
     */
    func setShareApp( _ body : [Any?] ){
        let params          = body[2] as! [Any?]
        let text            = params[0] as! String
        let things : [Any]  = [text]
        let avc = UIActivityViewController(activityItems:things, applicationActivities:nil)
        avc.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .message,
            .mail,
            .print,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .airDrop,
        ]
        self.target!.present(avc, animated:true)
    }
    
    
    /**
     보안키패드 오픈 입니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 바디 데이터 입니다.
     - Throws : False
     - returns :False
     */
    func setSecureKeyPadDisplay( _ body : [Any?] ){
        let params          = body[2] as! [Any?]
        /// 타입별 리턴 콜백을 받습니다.
        let callback        = body[0] as! Array<String>
        self.target!.view.endEditing(true);
        /// 보안키패드 디스플레이 타입을 받습니다.
        let padType         = params[0] as? String
        /// 최대 입력 카운트를 받습니다.
        let maxNumber       = params[1] as? Int
        let keypod = SecureKeyPadView.init(maxNumber: maxNumber!, padType: NC.S(padType)) { cbType in
            switch cbType {
            case .progress( let message ) :
                self.setEvaluateJavaScript(callback: callback[0], message: message)
            case .success( let message ) :
                self.setEvaluateJavaScript(callback: callback[1], message: message, isJson: true)
            case .fail( let message ) :
                self.setEvaluateJavaScript(callback: callback[2], message: message)
            default:
                break
            }
        }
        self.target!.view.addSubview(keypod)
        self.target!.view.addConstraintsToFit(keypod)
    }
    
    
    /**
     문자 보내기를 요청 합니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setSendSMS( _ body : [Any?] ){
        let params          = body[2] as! [Any?]
        /// SMS 통해서 공유하려는 문자 메시지를 받습니다.
        let smsMsg          = params[0] as! String
        
        /// 메세지를 문자로 공유 합니다.
        let messageVC                       = MFMessageComposeViewController()
        messageVC.body                      = smsMsg
        messageVC.recipients                = []
        messageVC.messageComposeDelegate    = self
        
        if MFMessageComposeViewController.canSendText() {
            /// 연결된 타켓 정보가 있는지를 체크 합니다.
            if let controller = self.target
            {
                controller.present(messageVC, animated: true, completion: nil)
            }
        }
    }
    
    
    /// 이미지 정상 저장 여부를 체크 합니다.
    @Published var imgSavePhoto : Bool = false
    /**
     웹 전체 화면 캡쳐 입니다. ( 저장 여부는 imgSavePhoto 여부로 체크 합니다. )
     - Date : 2023.03.29
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setWebViewCapture( _ body : [Any?] ){
        guard self.target != nil else { return }
        /// 현 웹뷰 전체 화면을 캡쳐 합니다
        guard let image = self.webView!.capture() else { return }
        
        /// 사진 저장 가능 여부 체크 입니다.
        self.viewModel.isPhotoSaveAuthorization().sink { success in
            if success
            {
                /// 이미지 저장 여부 이벤트를 체크 합니다.
                self.$imgSavePhoto.sink { success in
                    /// 타입별 리턴 콜백을 받습니다.
                    let callback = body[0] as! Array<String>
                    self.setEvaluateJavaScript(callback: callback[0], message: success == true ? "true" : "false")
                }.store(in: &self.cancellableSet)
                
                /// 겔러리 이미지 저장 요청 합니다.
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)),nil)
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /**
     겔러리에 이미지 저장 여부를 확인 합니다.
     - Date : 2023.03.29
     */
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil
        {
            self.imgSavePhoto = false
        }
        else
        {
            self.imgSavePhoto = true
        }
    }
    
    
    /// 업로드할 이미지를 받습니다.
    @Published var uploadImg : UIImage?
    /**
     사진첩에 이미지를 찾아 업도르 합니다. ( 업로드 이미지는 uploadImg 를 사용합니다. )
     - Date : 2023.03.29
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setGallerySendServer( _ body : [Any?] ){
        guard self.target != nil else { return }
        /// 이미지 업로드 여부를 체크 합니다.
        self.$uploadImg.sink { image in
            if image != nil
            {
                /// 사용하지 않는 것으로 확인 됩니다...
            }
        }.store(in: &self.cancellableSet)
        
        /// 이미지 피커 뷰를 사용 합니다.
        let picker              = UIImagePickerController()
        picker.sourceType       = .photoLibrary
        picker.mediaTypes       = [ kUTTypeImage as String]
        picker.delegate         = self
        picker.allowsEditing    = true
        self.target!.present(picker, animated: true)
    }
    
    
    /**
     사진첩에 이미지를 찾아 업도르 합니다. ( 업로드 이미지는 uploadImg 를 사용합니다. )
     - Date : 2023.03.29
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setLevelPop( _ body : [Any?] ){
        let params = body[2] as! [Any]
        /// 레벨 팝업을 오픈 합니다.
        LevelPopView().setLevelPopView(params: params)
    }
    
    
    /**
     오픈뱅킹 관련 외부 웹페이지 입니다.
     - Date : 2023.03.29
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setHybridOpenBank( _ body : [Any?] ){
        let params          = body[2] as! [Any]
        /// 오픈 뱅킹 웹 페이지를 디스플레이 합니다.
        let _ = HybridOpenBankViewController.init(pageURL: params[0] as! String ) { value in
            /// 웹페이지에 오픈 뱅킹 처리관련 부분을 스크립트로 넘깁니다.
            self.webView!.evaluateJavaScript(value) { ( anyData , error) in
                if (error != nil)
                {
                    //self.hideHudView()
                    print("error___1")
                }
            }
        }
    }
    
    
    /**
     로그아웃 요청 입니다.
     - Date : 2023.03.29
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setLogOut( _ body : [Any?] ){
        /// 로그아웃 요청 합니다.
        self.viewModel.setLogOut().sink { result in
            
        } receiveValue: { response in
            if response != nil
            {
                /// 전체 웹뷰 타입 경우인지를 체크 합니다.
                if let controller = self.target as? FullWebViewController
                {
                    controller.navigationController?.popViewController(animated: true, completion: {
                        /// 로그인 페이지를 오픈 합니다.
                        let viewController                      = LoginViewController()
                        self.target!.navigationController?.pushViewController(viewController, animated: true, animatedType: .up)
                    })
                    return
                }
                
                /// 연결된 타켓 정보가 있는지를 체크 합니다.
                if let controller = self.target
                {
                    /// 로그인 페이지를 오픈 합니다.
                    let viewController                      = LoginViewController()
                    controller.navigationController?.pushViewController(viewController, animated: true, animatedType: .up)
                }
            }
        }.store(in: &self.cancellableSet)
    }
    
    
    /**
     토큰 정보를 저장 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setSaveToken( _ body : [Any?] ){
        let messages = body[2] as! [Any?]
        if let token = messages[0] as? String
        {
            let custItem        = SharedDefaults.getKeyChainCustItem()
            custItem!.token     = token
            SharedDefaults.setKeyChainCustItem(custItem!)
        }
    }
    
    
    
    /**
     키체인에 데이터를 추가 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setPreference( _ body : [Any?] ){
        let params          = body[2] as! [String?]
        if params.count > 1
        {
            SharedDefaults.setKeyChain( NC.S(params[1]) , forKey: NC.S(params[0]) )
        }
    }
    
    
    /**
     키체인에서 데이터를 가져 옵니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getPreference( _ body : [Any?] ){
        let params          = body[2] as! [String?]
        if params.count > 0
        {
            let script      = SharedDefaults.getStringKeyChain(forKey: NC.S(params[0]))
            let callback    = body[0] as! [String?]
            self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: NC.S(script))
        }
    }
    
    
    /**
     날짜 선택 피커뷰를 디스플레이 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setDatePickerView( _ body : [Any?] ){
        let callback                = body[0] as! [String?]
        let params                  = body[2] as! [String?]
        // 날짜 선택할 수 있으로 Picker 뷰로 띄운다.
        var selectedDate : Date?    = nil
        
        let alert                   = UIAlertController(style: .actionSheet , title: "", message: "날짜 선택하세요")
        let minDtString             = NC.S(params[0])
        let maxDtString             = NC.S(params[1])
        let settingDtString         = NC.S(params[2])
        
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyyMMdd"
        
        var  minimumDate : Date?    = nil // 선택 가능한 최소일자
        var  maximumDate : Date?    = nil // 선택 가능한 최대일자
        var  settingDate : Date?    = nil // 선택 가능한 최대일자
        
        if minDtString != "" && minDtString.count == 8
        {
            if let minDt = dateFormatter.date(from: minDtString)
            {
                minimumDate = minDt
            }
        }
        
        if maxDtString != "" && maxDtString.count == 8
        {
            if let maxDt = dateFormatter.date(from: maxDtString)
            {
                maximumDate = maxDt
            }
        }
        
        if settingDtString != "" && settingDtString.count == 8
        {
            if let settingDt = dateFormatter.date(from: settingDtString)
            {
                settingDate = settingDt
            }
        }
        else
        {
            settingDate = Date()
        }
        
        alert.addDatePicker(mode: .date, date: settingDate , minimumDate: minimumDate, maximumDate: maximumDate) { date in
            selectedDate = date
        }
        alert.addAction(title: "완료", style: .cancel) { _ in
            if let date = selectedDate {
                let retStringDate = dateFormatter.string(from: date)
                self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: NC.S(retStringDate))
            } else {
                self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: NC.S(settingDtString))
            }
        }
        alert.show()
    }
    
    
    
    /**
     문자를 복사 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setPasteboard( _ body : [Any?] ){
        let params                  = body[2] as! [String?]
        let message                 = NC.S(params[0])
        UIPasteboard.general.string = message
    }
    
    
    /**
     OS 타입을 리턴 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getOSType( _ body : [Any?] ){
        let callback                  = body[0] as! [String?]
        self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: "iOS")
    }
    
    
    /**
     Device 정보를 리턴 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getDevice( _ body : [Any?] ){
        let callback                  = body[0] as! [String?]
        self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: NC.S(Utils().deviceModelName()))
    }
    
    
    /**
     AppVer 을 리턴 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getAppVer( _ body : [Any?] ){
        let callback     = body[0] as! [String?]
        var serverVerser = ""
        /// 앱 시작시 서버에서 받은 버전 정보를 체크 합니다.
        if let appStart = BaseViewModel.appStartResponse
        {
            serverVerser = appStart._data!._versionInfo!._version!
        }
        // 앱버전 조회
        let message : [String:Any] = [
            "app_version" : APP_VERSION,
            "server_version" : serverVerser, // 서버 관리하는 App 최신버전
            "os" : UIDevice.current.systemVersion, //  iOS, Android 버전
            "devname" : NC.S(Utils().deviceModelName()), // 디바이스명
        ]
        
        do {
            if let script = try Utils.toJSONString(message)
            {
                self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: script)
            }
        } catch { }
    }
    
    
    /**
     PUSH Token 정보를 리턴 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getPushToken( _ body : [Any?] ){
        let callback                = body[0] as! [String?]
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
                
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: token)
            }
        }
    }
    
    
    /**
     PUSH 사용여부 값을 리턴합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func getPushAuth( _ body : [Any?] ){
        let callback                = body[0] as! [String?]
        self.viewModel.isAPNSAuthorization().sink { success in
            self.setEvaluateJavaScript(callback: NC.S(callback[0]), message: success == true ? "Y" : "N")
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /**
     디바이스 설정으로 이동 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setMoveDeviceSetting(){
        UIApplication.openSettingsURLString.openUrl()
    }
    
    
    /**
     카카오톡 설치 여부를 리턴 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setIstalledKakaoTalk( _ body : [Any?] ){
        let callback        = body[0] as! [String?]
        self.setEvaluateJavaScript(callback: NC.S(callback[0]),
                                   message: UIApplication.shared.canOpenURL(URL(string: "kakaolink://")!) == true ? "Y" : "N")
    }
    
    
    /**
     앱 업데이트로 Apple Store 이동 합니다.
     - Date : 2023.03.31
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setAppUpdate(){
        if let appStart = BaseViewModel.appStartResponse
        {
            if let data = appStart._data
            {
                data._versionInfo!._market_url!.openUrl()
            }
        }
    }
    
    
    /**
     외부 브라우저를 실행 합니다.
     - Date : 2023.04.06
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setOutSideOpenUrl( _ body : [Any?] ){
        let params          = body[2] as! [Any]        
        if let info = params[0] as? [String:String]
        {
            /// 외부 오픈 URL 정보를 체크 합니다.
            if let linkUrl = info["url"] {
                linkUrl.openUrl()
            }
        }
    }
    
    
    /**
     현 페이지 POST 방식 새로고침 입니다.
     - Date : 2023.03.28
     - Parameters:
        - body : 스크립트에서 받은 메세지 입니다.
     - Throws : False
     - returns :False
     */
    func setCallRedirectPostUrl( _ body : [Any?] ){
        let params          = body[2] as! [Any]
        if let info = params[0] as? [String:Any]
        {
            /// 이동할 URL 정보 입니다.
            let urlString       = info["url"] as! String
            /// 헤더 정보 입니다.
            let headerFields    = info["header"] as! [String:String]
            /// post 전송할 바디 데이터 입니다.
            let postBody        = info["body"] as! String
            /// 전체 웹뷰 여부를 체크 합니다.
            if let controller = self.target as? FullWebViewController
            {
                controller.webView!.urlLoad(url: urlString,httpMethod: "POST" ,postData: postBody,headerFields: headerFields)
                return
            }
                    
            if let controller = self.target as? BaseViewController
            {
                /// 현 페이지에 웹뷰 디스플레이 여부를 체크 합니다.
                if controller.isWebViewHidden == false
                {
                    controller.webView!.urlLoad(url: urlString,httpMethod: "POST" ,postData: postBody,headerFields: headerFields)
                }
            }
        }
    }
    
    
    /**
     만보고 페이지로 이동 합니다.
     - Date : 2023.04.12
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setMoveToManboGo()
    {
        /// 만보기 접근 권한을 체크 합니다.
        HealthKitManager.healthCheck { value in
            /// 사용 가능합니다.
            if value
            {
                /// 만보기 약관 동의 여부를 체크 합니다.
                self.viewModel.getPTTermAgreeCheck().sink(receiveCompletion: { result in
                    
                }, receiveValue: { response  in
                    if response != nil
                    {
                        /// 약관 동의 여부를 체크 합니다.
                        if self.viewModel.PTAgreeResponse!.data!.pedometer_use_yn! == "N"
                        {
                            /// 약관동의 여부를 "N" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "N"
                            /// 약관 동의 "N" 으로 약관동의 팝업을 디스플레이 합니다.
                            self.setPedometerTermsViewDisplay()
                        }
                        else
                        {
                            /// 약관동의 여부를 "Y" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "Y"
                            /// 만보고 페이지로 이동 합니다.
                            DispatchQueue.main.async {
                                let mainStoryboard          = UIStoryboard(name: "Main", bundle: nil)
                                let vc                      = mainStoryboard.instantiateViewController(withIdentifier: "pedometerVC") as? PedometerViewController
                                vc?.modalPresentationStyle  = .overFullScreen
                                self.target!.navigationController?.pushViewController(vc!, animated: true, animatedType: .up)
                            }
                        }
                    }
                }).store(in: &self.viewModel.cancellableSet)
            }
            else
            {
                /// 만보기 서비스 이용활성화를 위해 설정으로 이동 안내 팝업 오픈 입니다.
                CMAlertView().setAlertView(detailObject: "만보기 서비스이용을 위해  \n 건강앱에 들어가셔서 데이터 접근 권한을 허용해주세요." as AnyObject, cancelText: "확인") { event in
                    "x-apple-health://".openUrl()
                }
            }
        }
    }
    
    
    /**
     만보고 약관동의 페이지를 디스플레이 합니다.
     - Date : 2023.04.12
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setPedometerTermsViewDisplay()
    {
        let terms = [TERMS_INFO.init(title: "서비스 이용안내", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001"),TERMS_INFO.init(title: "개인정보 수집·이용 동의", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S002")]
        BottomTermsView().setDisplay( target: self.target!, "도전! 만보GO 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                     termsList: terms) { value in
            /// 동의/취소 여부를 받습니다.
            if value == .success
            {
                /// 약관동의 처리를 요청합니다.
                self.viewModel.setPTTermAgreeCheck().sink { result in
                    
                } receiveValue: { response in
                    if response != nil
                    {
                        /// 약관동의가 정상처리 되었습니다
                        if response?.code == "0000"
                        {
                            /// 약관동의 여부를 "Y" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "Y"
                            DispatchQueue.main.async {
                                let mainStoryboard          = UIStoryboard(name: "Main", bundle: nil)
                                let vc                      = mainStoryboard.instantiateViewController(withIdentifier: "pedometerVC") as? PedometerViewController
                                vc?.modalPresentationStyle  = .overFullScreen
                                self.target!.navigationController?.pushViewController(vc!, animated: true, animatedType: .up)
                            }
                        }
                        /// 약관 동의 요청에 실패 하였습니다.
                        else
                        {
                            
                        }
                    }
                }.store(in: &self.viewModel.cancellableSet)
            }
            else
            {
                
            }
        }
    }
}




// MARK: - 공용 메서드 입니다.
extension WebMessagCallBackHandler{
    /**
     앱에서 웹으로 스크립트 처리 입니다.
     - Date : 2023.03.29
     - Parameters:
        - callback : 콜백 타입입니다.
        - message : 파라미터 정보 입니다.
        - isJson : Json 타입 데이터 인지를 체크 합니다.
     - Throws : False
     - returns :False
     */
    func setEvaluateJavaScript(callback: String, message : Any , isJson : Bool = false ) {
        /*
         iOSPluginJSNI.callbackFromNative('aaaa','20230412')
         */
        var scriptMsg = "iOSPluginJSNI.callbackFromNative('\(callback)'"
        if isJson
        {
            scriptMsg += ",\(message))"
        }
        else
        {
            if let message = message as? Array<String>
            {
                for item in message
                {
                    scriptMsg += ",'\(item)'"
                }
            }
            else if let message = message as? String
            {
                scriptMsg += ",'\(message)'"
            }
            else
            {
                scriptMsg += ",'\(message)'"
            }
            scriptMsg += ")"
        }
        
        print("scriptMsg:\(scriptMsg)")
        self.webView!.evaluateJavaScript(scriptMsg) { ( anyData , error) in
            if (error != nil)
            {
                //self.hideHudView()
                print("error___1")
            }
        }
    }
    
    
    /**
     페이지 종료처리 부분 입니다.
     - Date : 2023.03.28
     - Parameters:
        - callback : 콜백 메서드 입니다.
        - param : 종료시 넘기 파라미터 입니다.
     - Throws : False
     - returns :False
     */
    func setTargetDismiss( _ callback : String = "", param : String = "" ){
        /// 전체 웹뷰 타입 경우인지를 체크 합니다.
        if let controller = self.target as? FullWebViewController
        {
            controller.completion!(.scriptCall(collBackID: callback, message: NC.S(param) , controller: controller))
            /// 네비컨트롤러가 활성화 되는 컨트롤러인 경우 입니다.
            if let navigation = controller.navigationController
            {
                navigation.popViewController(animated: true, animatedType: .down, completion: {
                })
            }
            else
            {
                controller.dismiss(animated: true)
            }
            
        }
        
        /// 연결된 타켓 정보가 있는지를 체크 합니다.
        if let controller = self.target
        {
            /// 네비컨트롤러가 활성화 되는 컨트롤러인 경우 입니다.
            if let navigation = controller.navigationController
            {
                navigation.popViewController(animated: true, animatedType: .down, completion: {
                })
            }
            else
            {
                controller.dismiss(animated: true)
            }
        }
    }

    /**
     사용자명을 CNContact 의  property 속성을 문자로 리턴 합니다.
     - Date : 2023.04.17
     - Parameters:
        - contact : 선택된 연락처 정보 입니다.
     - Throws : False
     - returns :False
     */
    func conactName( contact: CNContact ) -> String {
        var contactName : String = ""
        if contact.familyName.count > 0
        {
            contactName += contact.familyName
        }
        if contact.middleName.count > 0
        {
            contactName += contact.middleName
        }
        if contact.givenName.count > 0
        {
            contactName += contact.givenName
        }
        return contactName
    }
}




// MARK: - setSendSMS : MFMessageComposeViewControllerDelegate
extension WebMessagCallBackHandler : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        /// 문자 디스플레이 컨트롤러를 종료 합니다.
        controller.dismiss(animated: true, completion: nil)
    }
}



// MARK: - UIImagePickerControllerDelegate
extension WebMessagCallBackHandler : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //var image = info[.originalImage] as? UIImage
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected dictionary containing an image, but was provided the following: \(info)")
        }
        /// 업로드할 이미지를 추가 합니다.
        self.uploadImg = selectedImage
        picker.dismiss(animated:true)
    }
}



// MARK: - CNContactPickerDelegate
extension WebMessagCallBackHandler : CNContactPickerDelegate {
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {}
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {}
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("contact : \(contact) ")
        print("contact.phoneNumbers : \(contact.phoneNumbers) ")
        
        /// 연락처의 전화번호가 1개 인 경우 입니다.
        if contact.phoneNumbers.count == 1
        {
            let phoneNumber     = contact.phoneNumbers.first
            let contactName     = conactName(contact: contact)
            let phoneString     = phoneNumber?.value.stringValue
            /// 웹에 전송할 연락처를 추가 합니다.
            self.contactInfo    = [contactName, phoneString!]
        }
        /// 연락처의 전화번호가 2개 이상인 경우 입니다.
        else
        {
            let contactVC                   = CNContactViewController(for: contact)
            contactVC.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            contactVC.delegate              = self
            contactVC.allowsEditing         = false
            contactVC.allowsActions         = false
            self.target!.navigationController?.pushViewController(contactVC, animated: false, animatedType: .up)
        }
    }
}



// MARK: - CNContactViewControllerDelegate
extension WebMessagCallBackHandler : CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        let contact         = property.contact
        let contactName     = conactName(contact: contact)
        let phoneString     = (property.value as! CNPhoneNumber).stringValue
        /// 웹에 전송할 연락처를 추가 합니다.
        self.contactInfo    = [contactName, phoneString]
        viewController.navigationController?.popViewController(animated: true,animatedType: .down,completion: {
            
        })
        return false
    }
}

