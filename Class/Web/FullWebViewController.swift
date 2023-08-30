//
//  FullWebViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/21.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

/**
 전체 웹 버튼 이벤트  입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
enum FULL_BTN : Int {
    /// 페이지 아래로 종료 입니다.
    case page_close = 10
    /// 페이지 이전 페이지 이동 입니다.
    case page_back  = 11
}


/**
 보안키패드 이벤트 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
enum KEY_PAD_CLOSE_TYPE : Int {
    /// 페이지 강제 종료 입니다.
    case close
    /// 인증 정상처리 입니다.
    case success
    /// 인증 실패 입니다.
    case fail
}


/**
 보안키패드 이벤트 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
enum OPENBANK_CLOSE_TYPE : Int {
    /// 페이지 강제 종료 입니다.
    case add_account
    /// 인증 정상처리 입니다.
    case page_close
    /// 인증 실패 입니다.
    case fail
}


/**
 전체 웹 종료 콜백 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
enum FULL_WEB_CB {
    /// 로그인 페이지 디스플레이 요청 입니다.
    case loginCall
    /// 페이지 종료후 바로 홈으로 이동합니다.
    case goToHome
    /// 오픈 뱅킹 디스플레이  입니다. ( success : 계좌 연동  정상 처리 여부, 종료시 웹 전송할 데이터 입니다.   )
    case openBank ( success : Bool, message : String  )
    /// 보안 키패드 타입 입니다. ( type : 보안 키패드 이벤트 타입 )
    case keyPadSucces( type : KEY_PAD_CLOSE_TYPE )
    /// 제로페이 인증용 보안 키패드 타입 입니다. ( barcode : 바코드, qrcode : QR코드 데이터 , maxValidTime : 최대 유지 타임 정보 )
    case zeroPaykeyPad( barcode : String, qrcode : String, maxValidTime : String )
    /// 제로페이 관련 페이지 닫기 입니다. ( 종료시 콜백 메세지 정보 입니다.)
    case zeroPayClose
    /// 페이지 닫기 입니다. ( 종료시 콜백 메세지 정보 입니다.)
    case pageClose ( message : String  )
    /// URL 정보를 넘깁니다
    case urlLink ( url : String )
    /// 스크립트 전송 입니다.
    case scriptCall ( collBackID : String, message : Any, controller : FullWebViewController )
}


/**
 전체 웹 페이지 타입 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.11
*/
enum FULL_PAGE_TYPE : String {
    /// 기본 타입 입니다.
    case default_type       = "DT"
    /// 약관동의 타입 입니다.
    case db_type            = "DB"
    /// PG 결제 연동 타입 입니다.
    case pg_type            = "PG"
    /// 제로페이 연동 타입 입니다.
    case zeropay_type       = "ZP"
    /// 오픈뱅킹 연동 타입 입니다.
    case openbank_type      = "OPENBANK"
    /// 인증용 보안키패드 연동 타입 입니다.
    case auth_keypad        = "AUTH_KEY_PAD"
    /// 제로페이 인증용 보안키패드 연동 타입 입니다.
    case zeropay_keypad     = "ZEROPAY_KEYPAD"
    /// 인증 관련 페이지 입니다.
    case auth_type          = "AUTH"
    /// 외부 웹페이지 접근으로 내부 도메인을 사용하지 않습니다.
    case outdside_type      = "OUTSIDE"
    /// 90일 동안 비밀번호 변경 요청 없는 경우 페이지 진입 입니다.
    case PW90_NOT_CHANGE    = "PW90_NOT_CHANGE"
    /// 닉네임 변경 페이지 진입 입니다.
    case NICKNAME_CHANGE    = "NICKNAME_CHANGE"
    /// 네이버 맵 모드 입니다.
    case NAVER_MAP          = "NAVER_MAP"
}



/**
 전체 웹 연동 페이지 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.28
*/
class FullWebViewController: BaseViewController {
    /// 뷰 모델 입니다.
    private var viewModel               : BaseViewModel { get { return self.baseViewModel }}
    /// 상단 타이틀바 영역 높이를 조정 합니다.
    @IBOutlet weak var titleBarHeight   : NSLayoutConstraint!
    /// 웹 페이지 디스플레이 영역 뷰어 입니다.
    @IBOutlet weak var webDisplayView   : UIView!
    /// 타이틀 정보 입니다.
    @IBOutlet weak var titleName        : UILabel!
    /// 뒤로가기 버튼 입니다.
    @IBOutlet weak var backBtn          : UIButton!
    /// 종료 버튼 입니다.
    @IBOutlet weak var closeBtn         : UIButton!
    /// 이벤트를 넘깁니다.
    var completion                      : (( _ webCBType : FULL_WEB_CB ) -> Void )? = nil
    /// 현 페이지 접근한 페이지 타입 입니다.
    var pageType                        : FULL_PAGE_TYPE = .default_type
    /// NicePay 에서 연결하는 URL 정보입니다.
    var pageURL                         : String        = ""
    /// 타이틀 정보를 저장 합니다.
    var titleText                       : String        = ""
    /// 타이틀바 디스플레이 여부를 가집니다.
    var titleBarHidden                  : Bool          = false
    /// 특정 상황에 파라미터를 이전 페이지 리턴 하는 경우 입니다.
    var returnParam                     : String        = ""
    /// 타이틀바 디스플레이 타입 입니다. ( 0 : 타이틀바 히든, 1 : 뒤로가기버튼, 2 : 종료 버튼 ) default : 0
    var titleBarType                    : Int           = 0
    /// 웹 디스플레이 여부를 체크 합니다.
    var startWebDisplay                 : Bool          = false
    /// 페이지 종료시 웹 데이터 체크할 스크립트 호출명 입니다.
    var closeScript                     : String?       = ""
    
    
    
    // MARK: - init
    /**
     전체 웹뷰 초기화 메서드 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.12
     - Parameters:
        - pageType          : 상단 네비 활성화시 타이틀 문구 입니다.
        - titleBarType : 타이틀바 디스플레이 타입 입니다. ( 0 : 타이틀바 히든, 1 : 뒤로가기버튼, 2 : 종료 버튼 ) default : 0
        - pageURL            : 연결할 페이지 URL 입니다.
        - returnParam   : 이전 페이지 그대로 넘겨줄 파라미터 정보 입니다.
        - closeScript   : 페이지 종료시 웹 데이터 체크 할 스크립트 입니다.
        - completion     : 페이지 종료시 콜백 핸들러 입니다.
     - Throws: False
     - Returns:False
     */
    init( pageType          : FULL_PAGE_TYPE = .default_type,
          title             : String = "",
          titleBarType      : Int = 0,
          titleBarHidden    : Bool = false,
          pageURL           : String = "",
          returnParam       : String = "",
          closeScript       : String = "",
          completion        : (( _ webCBType : FULL_WEB_CB ) -> Void )? = nil ) {
        super.init(nibName: nil, bundle: nil)
        /// 페이지 타입을 받습니다.
        self.pageType           = pageType
        /// 이벤트 정보를 리턴 하는 콜백입니다.
        self.completion         = completion
        /// 타이틀바 타입 입니다.
        self.titleBarType       = titleBarType
        /// 타이틀바 히든 여부를 가집니다.
        self.titleBarHidden     = titleBarHidden
        /// 타이틀 정보를 저장 합니다.
        self.titleText          = title
        /// 나이스 페이 연결할 URL 정보 입니다.
        self.pageURL            = pageURL
        /// 리턴 파라미터 정보를 연결 합니다.
        self.returnParam        = returnParam
        /// 페이지 종료시 웹 데이터 체크 할 스크립트 입니다.
        self.closeScript        = closeScript
        /// 웹뷰 히든 처리를 디폴트 false 값으로 설정 합니다.
        self.isWebViewHidden    = false
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 웹뷰 디스플레이 여부 체크 합니다.
        if self.isWebViewHidden == false
        {
            /// 웹뷰를 초기화 합니다.
            self.initWebView( self.webDisplayView, target: self )
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 웹 데이터 디스플레이 여부를 체크 합니다.
        if self.startWebDisplay == false
        {
            self.setWebViewDisplay()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     웹뷰 설정 및 디스플레이 메서드 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.17
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setWebViewDisplay()
    {
        /// 타이틀바 활성화 하며 뒤로 가기 버튼 입니다.
        if self.titleBarType == 1
        {
            self.backBtn.isHidden           = false
            self.closeBtn.isHidden          = true
            self.titleName.text             = title
            self.titleBarHeight.constant    = 56
        }
        
        /// 타이틀 활성화 하며 페이지 종료 입니다.
        if self.titleBarType == 2
        {
            self.backBtn.isHidden           = true
            self.closeBtn.isHidden          = false
            self.titleName.text             = title
            self.titleBarHeight.constant    = 56
        }
        
        /// 웹 데이터 디스플레이 체크 합니다.
        self.startWebDisplay    = true
        /// 타이틀을 세팅 합니다.
        self.titleName.text     = self.titleText
        Slog("self.pageURL : \(self.pageURL)")
        self.loadMainURL(self.pageURL)
    }
    
    
    /**
     종료 선택시 리턴 타입 체크 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.13
     - Parameters:
        - closeType : 종료시 리턴 타입을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setCloseCompletion( closeType : FULL_WEB_CB? = nil ) {
        if self.completion != nil
        {
            switch closeType
            {
                case .pageClose( let message) :
                    /// 오픈 뱅킹 여부 경우 타입을  openbank 으로 리턴 합니다.
                    if self.pageType == .openbank_type
                    {
                        self.completion!(.openBank(success: true, message: message))
                        return
                    }
                    self.completion!(closeType!)
                    break
                default:break
            }
        }
    }
    
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  FULL_BTN(rawValue: (sender as AnyObject).tag)
        {
            /// 종료시 리턴 메세지 입니다.
            var closeMessage = ""
            /// 종료시 기본 타입 정보를 스크립트로 넘깁니다.
            do {
                if let message = try Utils.toJSONString(["type":"\(self.pageType)","result":"CLOSE"]) { closeMessage = message }
            } catch {}
            switch type
            {
                case .page_back:
                    self.removeWebView()
                    self.popController(animated: true, animatedType: .right) { firstViewController in
                        /// 종료 콜백을 체크 합니다.
                        self.setCloseCompletion(closeType:.pageClose( message: closeMessage ))
                    }
                    break
                case .page_close:
                    self.removeWebView()
                    self.popController(animated: true, animatedType: .down) { firstViewController in
                        /// 종료 콜백을 체크 합니다.
                        self.setCloseCompletion(closeType:.pageClose( message: closeMessage ))
                    }
                    break
            }
        }
    }
}




// MARK: - WKNavigationDelegate,WKUIDelegate
extension FullWebViewController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode    = .mobile
        let request                         = navigationAction.request
        let optUrl                          = request.url
        let optUrlScheme                    = optUrl?.scheme
        guard let url = optUrl, let scheme = optUrlScheme
            else {
                return decisionHandler(.cancel, preferences)
        }
        Slog("url : \(url)")
        
        
        /// 페이지 타입이 네이버 맵 경우  네이버 블로그 진입시 예외로 별도의 화면을 디스플레이 합니다.
        if self.pageType == .NAVER_MAP,
           url.description.contains("m.blog.naver.com")
        {
            let naverBlogView = SFSafariViewController(url: url)
            naverBlogView.modalPresentationStyle = .overFullScreen
            self.present(naverBlogView, animated: true, completion: nil)
            decisionHandler(.cancel, preferences)
            return
        }
        
        
        /// 중간 중단으로 메인 페이지 이동 URL 확인 경우 입니다. ( 추후 WebToApp 으로 변경예정 )
        if url.description.contains("matcs/main.do")
        {
            self.popController(animated: true, animatedType: .down) { firstViewController in
                /// 종료 콜백을 체크 합니다.
                self.setCloseCompletion(closeType:.pageClose( message: "" ))
            }
            decisionHandler(.allow, preferences)
            return
        }
        
        /// 지갑 탭으로 이동 합니다.
        if url.description.contains("matcs/walletHome.do")
        {
            /// 0번째 페이지로 이동 후 월렛 홈으로 이동 합니다.
            self.popToRootController(animated: true, animatedType: .down) { firstViewController in
                /// 탭바가 연결되었다면 메인 페이지로 이동 합니다.
                if let tabbar = TabBarView.tabbar {
                    /// 진행중인 안내 뷰어를 전부 히든 처리 합니다.
                    tabbar.setCommonViewRemove()
                    /// 메인 탭 이동하면서 메인 페이지를 디스플레이 합니다.
                    tabbar.setSelectedIndex( .wallet )
                }
            }
            decisionHandler(.allow, preferences)
            return
        }
        
        /// 접근된 웹뷰 타입 체크 합니다.
        switch self.pageType
        {
            case .zeropay_type:
                ///제로페이 WebApp 스키마를 처리 합니다.
                self.setZeroPay(url: url, preferences: preferences, decisionHandler: decisionHandler)
                return
            default:break
        }
        
        ///. PG 결제 타입 경우 입니다.
        if( scheme != "http" && scheme != "https" ) {
            if( scheme == "ispmobile" && !UIApplication.shared.canOpenURL(url) ) {  //ISP 미설치 시
                "http://itunes.apple.com/kr/app/id369125087?mt=8".openUrl()
            } else if( scheme == "kftc-bankpay" && !UIApplication.shared.canOpenURL(url) ) {    //BANKPAY 미설치 시
                "http://itunes.apple.com/us/app/id398456030?mt=8".openUrl()
            } else {
                if( UIApplication.shared.canOpenURL(url) ) {
                    url.description.openUrl()
                } else {
                    //1. App 미설치 확인
                    //2. info.plist 내 scheme 등록 확인
                }
            }
        }
        decisionHandler(.allow, preferences)
    }
    
    
    /**
     제로페이 WebApp 스키마를 처리 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.25
     - Parameters:
        - url : URL 정보 입니다.
     - Throws: False
     - Returns:
        파라미터 정보를 정리하여 리턴 합니다. ([String : Any])
     */
    func setZeroPay( url : URL, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void ){
        let scheme   = NC.S(url.scheme)
        let event    = NC.S(url.host)
        
        /// URL에서 파라미터 정보를 가져 옵니다.
        self.viewModel.getURLParams(url: url).sink { urlParams in
            var params : [String:Any] = [:]
            if let param = urlParams { params = param }
            /// 제로페이에서 이벤트 발생 체크 합니다.
            if scheme.contains("webtoapp")
            {
                /// 제로페이 진입후 제로페이에서 화면 종료 이벤트 발생 입니다.
                if NC.S(event).contains("close")
                {
                    /// 웹뷰를 초기화 합니다.
                    self.removeWebView()
                    /// 현 페이지를 종료 합니다.
                    self.popController(animated: true, animatedType: .down) { firstViewController in
                        /// 이동 후 탭바를 새로고침 합니다.
                        TabBarView.setReloadSeleted(pageIndex: TabBarView.tabSeletedIndex)
                    }
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 제로페이 상품권으로 결제 요청시 사용자 인증 요청 이벤트 입니다.
                if NC.S(event).contains("user")
                {
                    /// 제로페이에서 GET 방식 URL 접근시 파라미터 정보를 정리하여 받아옵니다.
                    self.viewModel.getZeroPayURLParams(url: url).sink { param in
                        if let _ = param {
                            /// GET 방식 파라미터를 추가한 URL 정보를 가져 옵니다.
                            self.viewModel.getURLGetType(mainUrl: WebPageConstants.URL_ZERO_PAY_GIFTCARD_PAYMENT, params: params).sink { getUrl in
                                DispatchQueue.main.async {
                                    /// 전체 웹뷰를 호출 합니다.
                                    let controller = FullWebViewController.init(pageType: .zeropay_type, titleBarType: self.titleBarType, pageURL: getUrl) { webCBType in
                                        switch webCBType
                                        {
                                        case .scriptCall(let collBackID, _, _):
                                            self.webView!.evaluateJavaScript(collBackID) { ( anyData , error) in
                                                Slog(anyData as Any)
                                                Slog(error as Any)
                                            }
                                        default:break
                                        }
                                    }
                                    controller.view.backgroundColor     = .clear
                                    controller.modalPresentationStyle   = .overFullScreen
                                    self.pushController(controller, animated: true, animatedType: .up)
                                }
                            }.store(in: &self.viewModel.cancellableSet)
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                    
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 제로페이 상품권 구매,환불 선택시 이벤트 입니다.
                if NC.S(event).contains("transfer")
                {
                    /// GET 연결할 메인 URL 입니다.
                    var mainURL     = ""
                    /// 거래구분 코드 입니다. ( P:구매, C:환불 , M:신용카드구매환불 )
                    let dealDivCd   = NC.S(params["dealDivCd"] as? String) 
                    switch dealDivCd
                    {
                        /// 구매 입니다.
                        case "P":
                            mainURL = WebPageConstants.URL_ZERO_PAY_PURCHASE
                            break
                        /// 환불 입니다.
                        case "C":
                            mainURL = WebPageConstants.URL_ZERO_PAY_PURCHASE_CANCEL
                            break
                        /// 신용 카드 구매 환불 입니다.
                        case "M":
                            break
                        default:break
                    }
                    
                    /// 제로페이에서 GET 방식 URL 접근시 파라미터 정보를 정리하여 받아옵니다.
                    self.viewModel.getZeroPayURLParams(url: url).sink { param in
                        if let param = param {
                            /// GET 방식 파라미터를 추가한 URL 정보를 가져 옵니다.
                            self.viewModel.getURLGetType(mainUrl: mainURL, params: param).sink { getUrl in
                                /// 전체 웹뷰를 호출 합니다.
                                let controller =  FullWebViewController.init(pageType: .zeropay_type, pageURL: getUrl) { cbType in
                                    switch cbType
                                    {
                                    case .scriptCall(let collBackID, _, _):
                                        self.webView!.evaluateJavaScript(collBackID) { ( anyData , error) in
                                            Slog(anyData as Any)
                                            Slog(error as Any)
                                        }
                                    default:break
                                    }
                                }
                                self.pushController(controller, animated: true, animatedType: .up)
                            }.store(in: &self.viewModel.cancellableSet)
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 이전 히스토리로 이동 이벤트 발생 입니다.
                if NC.S(event).contains("historyBack")
                {
                    if self.webView!.canGoBack
                    {
                        self.webView!.goBack()
                    }
                    else
                    {
                        /// 웹 초기화 합니다.
                        self.removeWebView()
                        /// 현 페이지를 종료 합니다.
                        self.popController(animated: true, animatedType: .down)
                    }
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 외부 사파리 웹페이지로 이동 이벤트 합니다.
                if NC.S(event).contains("externalLink")
                {
                    if params.count > 0
                    {
                        let link = NC.S(params["url"] as? String)
                        if link.isValid { link.openUrl() }
                    }
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// QRCode 스캔 오픈 요청 이벤트 입니다.
                if NC.S(event).contains("qrCode")
                {
                    /// 제로페이에 데이터 리턴할 콜백 스크립트를 저장 합니다.
                    var scricptCB   = NC.S(params["callbackUrl"] as? String)
                    
                    /// 카메라 사용 권한을 체크 합니다.
                    self.viewModel.isCameraAuthorization().sink { value in
                        if value
                        {
                            OKZeroPayQRCaptureView(params: params) { qrCodeCB in
                                switch qrCodeCB
                                {
                                    /// QRCdoe 읽기 실패 입니다.
                                case .qr_fail,.cb_fail,.close :
                                        /// QRCode 스캔 실패로 아래 정보를 설정 합니다.
                                        params.updateValue("N", forKey: "result")
                                        params.updateValue("", forKey: "qrCode")
                                        DispatchQueue.main.async {
                                            do
                                            {
                                                /// 총 파라미터를 문자로 변경 합니다. (.utf8 인코딩 )
                                                if let cbParam = try Utils.toJSONString(params)
                                                {
                                                    scricptCB += "('\(cbParam)')"
                                                    self.webView!.evaluateJavaScript(scricptCB) { ( anyData , error) in
                                                        Slog(anyData as Any)
                                                        Slog(error as Any)
                                                    }
                                                }
                                            }catch{
                                                Slog("QrCode toJSONString Error")
                                            }
                                            OKZeroPayQRCaptureView().hide()
                                        }
                                    /// QRCode 정보를 넘깁니다
                                    case .qr_success(let qrcode) :
                                        /// QRCode 스캔 실패로 아래 정보를 설정 합니다.
                                        params.updateValue("Y", forKey: "result")
                                        params.updateValue(NC.S(qrcode), forKey: "qrCode")
                                        DispatchQueue.main.async {
                                            do
                                            {
                                                /// 총 파라미터를 문자로 변경 합니다. (.utf8 인코딩 )
                                                if let cbParam = try Utils.toJSONString(params)
                                                {
                                                    scricptCB += "('\(cbParam)')"
                                                    Slog("QrCode Success : \(scricptCB)")
                                                    self.webView!.evaluateJavaScript(scricptCB) { ( anyData , error) in
                                                        Slog(anyData as Any)
                                                        Slog(error as Any)
                                                    }
                                                }
                                            }catch{
                                                Slog("QrCode toJSONString Error")
                                            }
                                            OKZeroPayQRCaptureView().hide()
                                        }
                                        break
                                    /// QRCode 인증 정상처리 후 받은 스크립트를 넘깁니다.
                                    case .cb_success( let scricpt ) :
                                        /// 제로페이에 QRCode 데이터를 전송 합니다.
                                        DispatchQueue.main.async {
                                            self.webView!.evaluateJavaScript(NC.S(scricpt)) { ( anyData , error) in
                                                Slog(anyData as Any)
                                                Slog(error as Any)
                                            }
                                            OKZeroPayQRCaptureView().hide()
                                        }
                                    default:break
                                }
                                return
                            }.show()
                        }
                        else
                        {
                            /// 카메라 접근 안내 팝업 입니다.
                            CMAlertView().setAlertView(detailObject: "카메라 접근 서비스이용을 위해  \n 데이터 접근 권한을 허용해주세요." as AnyObject, cancelText: "확인") { event in
                                /// QRCode 스캔 실패로 아래 정보를 설정 합니다.
                                params.updateValue("N", forKey: "result")
                                params.updateValue("", forKey: "qrCode")
                                DispatchQueue.main.async {
                                    do
                                    {
                                        /// 총 파라미터를 문자로 변경 합니다. (.utf8 인코딩 )
                                        if let cbParam = try Utils.toJSONString(params)
                                        {
                                            scricptCB += "('\(cbParam)')"
                                            self.webView!.evaluateJavaScript(scricptCB) { ( anyData , error) in
                                                Slog(anyData as Any)
                                                Slog(error as Any)
                                            }
                                        }
                                    }catch{
                                        Slog("QrCode toJSONString Error")
                                    }
                                }
                                
                                UIApplication.openSettingsURLString.openUrl()
                            }
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                    
                    
                }
                else
                {
                    return
                }
            }
            decisionHandler(.allow, preferences)
            return
        }.store(in: &self.viewModel.cancellableSet)
    }
}
