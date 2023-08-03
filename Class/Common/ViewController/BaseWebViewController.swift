//
//  BaseWebViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit
import WebKit


/**
 웹 링크 연결시 진행 타입 값입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.06.23
*/
enum WEBVIEW_DID_STATUS {
    /// 대기 상태 입니다.
    case stay
    /// 연결 시작 입니다.
    case start
    /// 연결중 입니다.
    case ing
    /// 정상 처리 완료 입니다.
    case finish
    /// 연결 오류 입니다.
    case fail
}



/**
 기본 베이스 웹 컨트롤뷰 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
class BaseWebViewController: UIViewController {
    var baseViewModel           : BaseViewModel = BaseViewModel()
    /// 웹 화면 디스플레이 입니다.
    var webView                 : WKWebView?
    /// 웹 이벤트에서 주고받을 메세지 핸들러 입니다.
    var messageHandler          : WebMessagCallBackHandler?
    /// 웹뷰는 기본 히든 처리 상태 입니다.
    var isWebViewHidden         : Bool = true
    /// 쿠키를 변경 할지 여부를 받습니다.
    var updateCookies           : Bool = true
    /// 코드 선택시 이벤트 입니다.
    var webLoadCompletion       : (( _ success : Bool ) -> Void)? = nil
    /// 웹 화면 데이터 새로고침 컨트롤 입니다.
    var webViewRefresh          : UIRefreshControl?
    /// 웝 화면 새로고침 활성화 여부 입니다.
    var webViewRefreshEnabled   : Bool = true
    /// 웹 링크 연결 진행 상태 값을 가집니다.
    var webViewDidStatus        : WEBVIEW_DID_STATUS = .stay
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     WebView 를 초기화 합니다.. ( J.D.H VER : 1.24.43 )
     - description: WKWebView 를 초기화 하며  javaScript 이벤트를 등록 할 messagwhandler 를 초기화 합니다. 추가되는 핸들러는 "SCRIPT_MESSAGE_HANDLER_TYPE" 의 핸들러를 추가 합니다.
     - Date: 2023.06.08
     - Parameters:
        - view : 웹뷰 추가할 뷰어 입니다.
        - target : 핸들러 연결 할 controller 입니다.
        - webTopRefresh : 웹뷰 새로고침 여부를 받습니다.
     - Returns:False
     */
    func initWebView( _ view : UIView, target : UIViewController, webTopRefresh : Bool = true ) {
        /// 웹 메세지 핸들러를 연결 합니다.
        self.messageHandler                 = WebMessagCallBackHandler( webViewController: self )
        /// 도메인의 쿠키 정보를 가져 옵니다.
        let cookies                         = HTTPCookieStorage.shared.cookies(for: URL(string: WebPageConstants.baseURL)!)
        /// 업데이트할 쿠키 스크립트를 요청 합니다.
        self.baseViewModel.getJSCookiesString(cookies: cookies).sink { script in
            let contentController                                   = WKUserContentController()
            contentController.removeAllUserScripts()
            let cookieScript                                        = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            contentController.addUserScript(cookieScript)
            let updateScript                                        = WKUserScript(source: "window.webkit.messageHandlers.updateCookies.postMessage(document.cookie);", injectionTime: .atDocumentStart, forMainFrameOnly: false)
            contentController.addUserScript(updateScript)
            /// 스크립트를 연결 합니다.
            for scriptmsg in SCRIPT_MESSAGE_HANDLER_TYPE.allCases
            {
                contentController.add(self, name: scriptmsg.rawValue)
            }
            self.messageHandler!.config.userContentController       = contentController
            self.messageHandler!.config.applicationNameForUserAgent = "/GA_iOS_WK"
            self.webView                                            = WKWebView(frame: self.view.frame, configuration: self.messageHandler!.config)
            self.webView!.uiDelegate                                = self
            self.webView!.navigationDelegate                        = self
            if #available(iOS 14.0, *) {
                self.webView!.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            } else {
                self.webView!.configuration.preferences.javaScriptEnabled = true
            }
            self.webView!.allowsBackForwardNavigationGestures       = false            
            self.webView!.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
                if error == nil
                {
                    if let userAgent = result as? String {
                        self?.webView!.customUserAgent = userAgent + " iOS-Oligo " + "iOS-APP"
                    }
                }
            }
            self.webView!.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            self.webView!.translatesAutoresizingMaskIntoConstraints = false
            self.webView!.allowsLinkPreview                         = false
            self.messageHandler!.webView                            = self.webView
            self.messageHandler!.target                             = target
            view.addSubview(self.webView!)
            view.addConstraintsToFit(self.webView!)
            /// 웹뷰 새로고침 여부를 받습니다.
            self.webViewRefreshEnabled = webTopRefresh
            /// 새로고침 여부를 최초 한번 추가 합니다.
            if self.webViewRefresh == nil,
               self.webViewRefreshEnabled == true
            {
                self.webView!.scrollView.refreshControl = self.getWebViewRefreshController()
            }
        }.store(in: &self.baseViewModel.cancellableSet)
    }
    
    
    /**
     내자산 뷰어 새로고침 컨트롤러를 생성 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.06.08
     - Returns:
        내 자산 정보 새로고침 컨트롤을 리턴 합니다. (UIRefreshControl)
     */
    func getWebViewRefreshController() -> UIRefreshControl
    {
        self.webViewRefresh                  = UIRefreshControl()
        self.webViewRefresh!.addTarget(self, action: #selector(setWebViewRefreshTable(webViewRefresh:)), for: .valueChanged)
        self.webViewRefresh!.backgroundColor = .clear
        self.webViewRefresh!.tintColor       = .gray
        self.webViewRefresh!.isHidden        = true
        return self.webViewRefresh!
    }
    
    
    /**
     웹뷰 새로고침 이벤트 요청 액션 입니다.  ( J.D.H VER : 1.24.43 )
     - Date: 2023.06.08
     - Parameters:
        - webViewRefresh : 내자산 새로고침 컨트롤러 입니다.
     - Returns:False
     */
    @objc func setWebViewRefreshTable( webViewRefresh : UIRefreshControl )
    {
        self.webView!.reload()
    }
    
    
    /**
     탭 이동시 현 페이지가 빈화면으로 새로고침을 해야하는 상황인지를 체크후 URL 로드 합니다.   ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.21
     - Parameters:
        - url : 디스플레이할 웹 페이지 입니다.
     - Returns:False
     */
    func loadTabPageURL( _ url: String, load : Bool = false ) {
        if let utrStr = self.webView?.url?.absoluteString,
           utrStr == "about:blank"
        {
            self.loadMainURL(url)
        }
    }
    
    
    /**
     URL 정보를 받아 화면에 디스플레이 합니다.   ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.20
     - Parameters:
        - url : 디스플레이할 웹 페이지 입니다.
        - updateCookies : 쿠키를 변경 할지 여부를 받습니다.
        - loadCompletion : 웹 페이지 정상 로드 확인 입니다.
     - Returns:False
     */
    func loadMainURL( _ url: String, updateCookies : Bool = false, loadCompletion : (( _ success : Bool ) -> Void)? = nil  ) {
        self.isWebViewHidden    = false
        self.updateCookies      = updateCookies
        DispatchQueue.main.async {
            if self.webView != nil
            {
                self.webView!.isHidden  = false
                self.webLoadCompletion = loadCompletion
                Slog("webView!.urlLoad : \(url)")
                self.webView!.urlLoad(url: url)
            }
        }
    }
    
        
    /**
     웹 페이지를 빈화면으로 설정 합니다 ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.20
     - Parameters:False
     - Returns:False
     */
    func initWebPage(){
        if self.messageHandler != nil
        {
            /// 웹 화면 히스토리를 초기화 합니다.
            self.webView!.clearHistory()
            /// 화면을 초기화 합니다.
            self.webView!.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
}



//MARK: - WKNavigationDelegate
extension BaseWebViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        /// 웹 연결 상태를 시작으로 합니다.
        self.webViewDidStatus = .start
        /// 빈 배경 설정으로 리턴 합니다.
        if webView.url!.absoluteString == "about:blank" { return }
        Slog("webView didStartProvisionalNavigation url : \(webView.url!.absoluteString)", category: .network)
        LoadingView.default.show()
        /// 네트웤 가용가능 여부 체크 합니다.
        BaseViewModel.shared.isNetConnected = .checking
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /// 웹 연결 상태를 완료처리 합니다.
        self.webViewDidStatus = .finish
        /// 빈 배경 설정으로 리턴 합니다.
        if webView.url!.absoluteString == "about:blank" { return }
        Slog("webView didFinish url : \(webView.url!.absoluteString)", category: .network)
        Slog("webView backForwardList count : \(webView.backForwardList.backList.count)", category: .network)
        /// 웹 로드 완료 리턴 CB 체크 입니다.
        if let loadCompletion = self.webLoadCompletion { loadCompletion(true) }
        /// 새로고침 중인지를 체크 후 새로고침 뷰어를 종료 합니다.
        if self.webViewRefresh!.isRefreshing == true { self.webViewRefresh!.endRefreshing() }
        
        /// 웹페이지 정상 디스플레이 완료후 쿠키를 업데이트 합니다.
        if self.updateCookies == true
        {
            self.updateCookies  = false
            /// 연결 도메인의 쿠키 정보를 가져 옵니다.
            let cookies         = HTTPCookieStorage.shared.cookies(for: URL(string: WebPageConstants.baseURL )!)
            /// 업데이할 쿠키 정보를 스크립트로 가져 옵니다.
            self.baseViewModel.getJSCookiesString(cookies: cookies).sink { script in
                self.webView!.evaluateJavaScript(script) { ( anyData , error) in
                    Slog("updateCookies anyData:\(anyData as Any)")
                    Slog("updateCookies error:\(error as Any)")
                    Slog("updateCookies script:\(script)")
                }
                webView.configuration.userContentController.removeAllUserScripts()
            }.store(in: &self.baseViewModel.cancellableSet)
        }
         
        LoadingView.default.hide()
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /// 웹 연결 상태를 시작으로 합니다.
        self.webViewDidStatus = .fail
        /// 빈 배경 설정으로 리턴 합니다.
        if webView.url!.absoluteString == "about:blank" { return }
        Slog("webView didFail url : \(webView.url!.absoluteString)", category: .network)
        /// 웹 로드 완료 리턴 CB 체크 입니다.
        if let loadCompletion = self.webLoadCompletion { loadCompletion(true) }
        /// 새로고침 중인지를 체크 후 새로고침 뷰어를 종료 합니다.
        if self.webViewRefresh!.isRefreshing == true { self.webViewRefresh!.endRefreshing() }
        LoadingView.default.hide()
        /// 에러 코드값을 체크 합니다.
        self.webViewFailErrorCode(withError: error)
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /// 웹 연결 상태를 시작으로 합니다.
        self.webViewDidStatus = .fail
        /// 빈 배경 설정으로 리턴 합니다.
        if webView.url!.absoluteString == "about:blank" { return }
        Slog("webView didFailProvisionalNavigation url : \(webView.url!.absoluteString)", category: .network)
        /// 웹 로드 완료 리턴 CB 체크 입니다.
        if let loadCompletion = self.webLoadCompletion { loadCompletion(true) }
        /// 새로고침 중인지를 체크 후 새로고침 뷰어를 종료 합니다.
        if self.webViewRefresh!.isRefreshing == true { self.webViewRefresh!.endRefreshing() }
        LoadingView.default.hide()
        /// 에러 코드값을 체크 합니다.
        self.webViewFailErrorCode(withError: error)
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        /// 취약점 점검인 경우 입니다.
        if APP_INSPECTION
        {
            /// 해당 도메인의 SSL 인증서 우회를 설정 합니다.
            if challenge.protectionSpace.host.contains(WebPageConstants.baseURL){
                let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)                
                completionHandler(.useCredential, urlCredential)
            }else{
                completionHandler(.performDefaultHandling, nil)
            }
        }
        else
        {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    
    func webViewFailErrorCode( withError error: Error )
    {
        if(error._code == -1001/*request time out*/
           || error._code == -1103/*resource exceeds maximum size.*/
           || error._code == -1004/*Could not connect to the server.*/
           || error._code == -999 /* NSURLErrorDomain */) {
            Slog("webViewFailErrorCode : \(error._code)", category: .network)
        }
    }
}



// MARK: - WKUIDelegate
extension BaseWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        CMAlertView().setAlertView(detailObject: message as AnyObject, cancelText: "확인") { event in
            completionHandler()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        /// 업데이트 안내 팝업 입니다.
        let alert = CMAlertView().setAlertView( detailObject: message as AnyObject )
        alert?.addAlertBtn(btnTitleText: "취소", completion: { result in
            completionHandler(false)
        })
        alert?.addAlertBtn(btnTitleText: "확인", completion: { result in
            completionHandler(true)
        })
        alert?.show()
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    ///WKNavigationDelegate 중복적으로 리로드 방지 (iOS 9 이후지원)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        weak var createWebView = createWebView(frame: view.bounds, configuration: configuration)
        if createWebView != nil {
            view.addSubview(createWebView!)
        }
        return createWebView
    }
    
    
    func webViewDidClose(_ webView: WKWebView) {
        closeWebView(webView)
    }
    
    
    // MARK: - WKUIDelegate 지원 메서드 입니다.
    func createWebView(_ withTag: Int = 100, frame: CGRect, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) -> WKWebView {
        let createWebView = WKWebView(frame: frame, configuration: configuration)
        createWebView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        createWebView.uiDelegate = self
        createWebView.tag = withTag
        return createWebView
    }
    
    
    func closeWebView(_ removeAll: Bool = false, withTag: Int) {
        if removeAll {
            for view in view.subviews {
                if view.tag != 0 {
                    view.removeFromSuperview()
                }
            }
        } else {
            view.viewWithTag(withTag)?.removeFromSuperview()
        }
    }
    
    
    func closeWebView(_ webView: WKWebView?) {
        for view in view.subviews {
            if webView == view {
                view.removeFromSuperview()
            }
        }
    }
}



//MARK: - WKScriptMessageHandler
extension BaseWebViewController: WKScriptMessageHandler {
    /**
     Web 에서 ScriptMessage 받는 메서드 입니다. ( J.D.H VER : 1.24.43 )
     - Description : hybridscript, updateCookies 헨들러 이벤트를 받아 WebAPP 인터페이스를 처리 합니다.
     - Date: 2023.03.28
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let weblog = """
        _\n\n----------------------------- WebView Script Open -------------------------------
        [Script Name]: \n\(message.name)
        [Script Bady]: \n\(message.body)
        ----------------------------- WebView Script End --------------------------------
        _\n
        """
        Slog("\(weblog)", category: .network)
        /// 쿠키 업데이트 메세지 이벤트 입니다.
        if message.name == "\(SCRIPT_MESSAGE_HANDLER_TYPE.updateCookies)"
        {
            Slog("\(SCRIPT_MESSAGE_HANDLER_TYPE.updateCookies) : \(message.body)")
            /// 연결 도메인의 쿠키 정보를 가져 옵니다.
            let cookies         = HTTPCookieStorage.shared.cookies(for: URL(string: WebPageConstants.baseURL )!)
            /// 업데이할 쿠키 정보를 스크립트로 가져 옵니다.
            self.baseViewModel.getJSCookiesString(cookies: cookies).sink { script in
                self.webView!.evaluateJavaScript(script) { ( anyData , error) in
                    Slog("updateCookies anyData:\(anyData as Any)", category: .network)
                    Slog("updateCookies error:\(error as Any)", category: .network)
                    Slog("updateCookies script:\(script)", category: .network)
                }
            }.store(in: &self.baseViewModel.cancellableSet)
            return
        }
        
        // 쿠키 업데이트 메세지 이벤트 입니다.
        if message.name == "\(SCRIPT_MESSAGE_HANDLER_TYPE.okpaygascriptCallbackHandler)"
        {
            Slog("\(SCRIPT_MESSAGE_HANDLER_TYPE.okpaygascriptCallbackHandler) : \(message.body)")
            /// GA 이벤트를 넘깁니다.
            do { try messageHandler?.didReceiveGAMessage(message: message) }
            catch{}
            return
        }
        
        /// hybridscript 메세지 이벤트를 넘깁니다.
        messageHandler?.didReceiveMessage(message: message)
    }
}




