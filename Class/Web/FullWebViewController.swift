//
//  FullWebViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/21.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit
import WebKit



enum FULL_BTN : Int {
    /// 페이지 아래로 종료 입니다.
    case page_close = 10
    /// 페이지 이전 페이지 이동 입니다.
    case page_back  = 11
}
/**
 전체 웹 종료 콜백 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.21
*/
enum FULL_WEB_CB {
    /// 로그인 페이지 디스플레이 요청 입니다.
    case loginCall
    /// 페이지 닫기 입니다.
    case pageClose
    /// URL 정보를 넘깁니다
    case urlLink ( url : String )
    /// 스크립트 전송 입니다.
    case scriptCall ( collBackID : String, message : Any, controller : FullWebViewController )
}


/**
 전체 웹 페이지 타입 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.11
*/
enum FULL_PAGE_TYPE : String {
    /// 기본 타입 입니다.
    case default_type   = "DT"
    /// 약관동의 타입 입니다.
    case db_type        = "DB"
    /// PG 결제 연동 타입 입니다.
    case pg_type        = "PG"
    /// 제로페이 연동 타입 입니다.
    case zeropay_type   = "ZP"
    /// 인증 관련 페이지 입니다.
    case auth_type      = "AUTH"
    /// 외부 웹페이지 접근으로 내부 도메인을 사용하지 않습니다.
    case outdside_type  = "OUTSIDE"
}



/**
 전체 웹 연동 페이지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.28
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
    
    
    // MARK: - init
    /**
     전체 웹뷰 초기화 메서드 입니다.
     - Date : 2023.04.12
     - Parameters:
        - pageType      : 상단 네비 활성화시 타이틀 문구 입니다.
        - titleBarType  : 타이틀바 디스플레이 타입 입니다. ( 0 : 타이틀바 히든, 1 : 뒤로가기버튼, 2 : 종료 버튼 ) default : 0
        - pageURL       : 연결할 페이지 URL 입니다.
        - returnParam   : 이전 페이지 그대로 넘겨줄 파라미터 정보 입니다.
        - completion    : 페이지 종료시 콜백 핸들러 입니다.
     - Throws : False
     - returns :False
     */
    init( pageType          : FULL_PAGE_TYPE = .default_type,
          title             : String = "",
          titleBarType      : Int = 0,
          titleBarHidden    : Bool = false,
          pageURL           : String = "",
          returnParam       : String = "",
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
        // Do any additional setup after loading the view.
        self.setWebViewDisplay()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     웹뷰 설정 및 디스플레이 메서드 입니다.
     - Date : 2023.03.17
     - Parameters:False
     - Throws : False
     - returns :False
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
        
        /// 타이틀을 세팅 합니다.
        self.titleName.text = self.titleText
        Slog("self.pageURL : \(self.pageURL)")
        self.loadMainURL(self.pageURL)
    }
    
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  FULL_BTN(rawValue: (sender as AnyObject).tag)
        {
            switch type
            {
                case .page_back:
                    self.popController(animated: true, animatedType: .right) { firstViewController in
                        if self.completion != nil
                        {
                            self.completion!(.pageClose)
                        }
                    }
                    break
                case .page_close:
                    self.popController(animated: true, animatedType: .down) { firstViewController in
                        if self.completion != nil
                        {
                            self.completion!(.pageClose)
                        }
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
        
        /// 중간 중단으로 메인 페이지 이동 URL 확인 경우 입니다. ( 추후 WebToApp 으로 변경예정 )
        if url.description.contains("matcs/main.do")
        {
            self.popController(animated: true, animatedType: .down) { firstViewController in
                if self.completion != nil
                {
                    self.completion!(.pageClose)
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
        
        /// 계좌 등록 페이지 호출시 입니다. ( 추후 WebToApp 으로 변경예정 )
        if url.description.contains("myp/mypAccountList.do")
        {
            if self.pageURL.contains("myp/mypAccountList.do") {
                decisionHandler(.allow, preferences)
                return
            }
            
            self.popController(animated: true, animatedType: .down) { firstViewController in
                if self.completion != nil
                {
                    self.completion!( .urlLink(url: "myp/mypAccountList.do"))
                }
            }
            decisionHandler(.allow, preferences)
            return
        }
        
        
        
        
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
     제로페이 WebApp 스키마를 처리 합니다.
     - Date : 2023.04.25
     - Parameters:
        - url : URL 정보 입니다.
     - Throws : False
     - returns :
        - [String : Any]
            + 파라미터 정보를 정리하여 리턴 합니다.
     */
    func setZeroPay( url : URL, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void ){
        let scheme   = NC.S(url.scheme)
        let event    = NC.S(url.host)
        /// URL에서 파라미터 정보를 가져 옵니다.
        self.viewModel.getURLParams(url: url).sink { params in
            /// 제로페이에서 이벤트 발생 체크 합니다.
            if scheme.contains("webtoapp")
            {
                /// 제로페이 진입후 제로페이에서 화면 종료 이벤트 발생 입니다.
                if NC.S(event).contains("close")
                {
                    /// 현 페이지를 종료 합니다.
                    self.popController(animated: true, animatedType: .down)
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 제로페이 상품권으로 결제 요청시 사용자 인증 요청 이벤트 입니다.
                if NC.S(event).contains("user/v2/auth")
                {
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
                            controller.view.backgroundColor = .clear
                            self.pushController(controller, animated: true, animatedType: .up)
                        }
                    }.store(in: &self.baseViewModel.cancellableSet)
                    decisionHandler(.allow, preferences)
                    return
                }
                
                /// 제로페이 상품권 구매,환불 선택시 이벤트 입니다.
                if NC.S(event).contains("transfer/v2/auth")
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
                            mainURL = WebPageConstants.URL_ZERO_PAY_PURCHASE
                            break
                        /// 신용 카드 구매 환불 입니다.
                        case "M":
                            break
                        default:break
                    }
                    
                    /// GET 방식 파라미터를 추가한 URL 정보를 가져 옵니다.
                    self.viewModel.getURLGetType(mainUrl: mainURL, params: params).sink { getUrl in
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
                    }.store(in: &self.baseViewModel.cancellableSet)
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
                    /// 파라미터를 세팅 합니다.
                    var params      = params
                    /// 제로페이에 데이터 리턴할 콜백 스크립트를 저장 합니다.
                    var scricptCB   = NC.S(params["callbackUrl"] as? String)
                    ///  QRCode 스캔 하는 전체 화면 뷰어를 호출 합니다.
                    OKZeroPayQRCaptureView(completion: { qrCodeCB in
                        switch qrCodeCB
                        {
                            /// QRCdoe 읽기 실패 입니다.
                            case .qr_fail,.cb_fail :
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
                            /// QRCode 페이지 종료 입니다.
                            case .close :
                                OKZeroPayQRCaptureView().hide()
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
                        decisionHandler(.allow, preferences)
                        return
                    }, params: params).show()
                }
                else
                {
                    decisionHandler(.allow, preferences)
                    return
                }
            }
            decisionHandler(.allow, preferences)
            return
        }.store(in: &self.baseViewModel.cancellableSet)
    }
}
