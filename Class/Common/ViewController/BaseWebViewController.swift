//
//  BaseWebViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit
import WebKit


/**
 기본 베이스 웹 컨트롤뷰 입니다.
 - Date : 2023.03.20
 */

class BaseWebViewController: UIViewController, WKNavigationDelegate {
    var baseViewModel       : BaseViewModel = BaseViewModel()
    /// 웹 화면 디스플레이 입니다.
    var webView             : WKWebView?
    /// 웹 이벤트에서 주고받을 메세지 핸들러 입니다.
    var messageHandler      : WebMessagCallBackHandler?
    /// 웹뷰는 기본 히든 처리 상태 입니다.
    var isWebViewHidden     : Bool = true
    /// 쿠키를 변경 할지 여부를 받습니다.
    var updateCookies       : Bool = true
    
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    func initWebView( _ view : UIView, target : UIViewController ) {
        /// 웹 메세지 핸들러를 연결 합니다.
        self.messageHandler                 = WebMessagCallBackHandler( webViewController: self )
        /// 도메인의 쿠키 정보를 가져 옵니다.
        let cookies                         = HTTPCookieStorage.shared.cookies(for: URL(string: AlamofireAgent.domainUrl)!)
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
        }.store(in: &self.baseViewModel.cancellableSet)
    }
    
    
    /**
     탭 이동시 현 페이지가 빈화면으로 새로고침을 해야하는 상황인지를 체크후 URL 로드 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.21
     - Parameters:
        - url : 디스플레이할 웹 페이지 입니다.
     - returns :False
     */
    func loadTabPageURL( _ url: String ) {
        if self.webView?.url?.absoluteString == "about:blank"
        {
            self.loadMainURL(url)
        }
    }
    
    
    /**
     URL 정보를 받아 화면에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:
        - url : 디스플레이할 웹 페이지 입니다.
        - updateCookies : 쿠키를 변경 할지 여부를 받습니다.
     - returns :False
     */
    func loadMainURL( _ url: String, updateCookies : Bool = false  ) {
        self.isWebViewHidden    = false
        self.updateCookies      = updateCookies
        DispatchQueue.main.async {
            if self.webView != nil
            {
                self.webView!.isHidden  = false
                Slog("webView!.urlLoad : \(url)")
                self.webView!.urlLoad(url: url)
            }
        }
    }
    
    
    
    /**
     웹 페이지를 빈화면으로 설정 합니다 ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:False
     - returns :False
     */
    func initWebPage(){
        if self.messageHandler != nil
        {
            /// 웹 화면 케시를 전부 삭제 합니다.
            self.messageHandler!.setWebViewClearCache()
            /// 웹 화면 히스토리를 초기화 합니다.
            self.webView!.clearHistory()
            /// 화면을 초기화 합니다.
            self.webView!.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
    
    
    
    //MARK: - WKWebView callback
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
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        Slog("webView didStartProvisionalNavigation")
        LoadingView.default.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Slog("webView didFinish")
        /// 웹페이지 정상 디스플레이 완료후 쿠키를 업데이트 합니다.
        if self.updateCookies == true
        {
            self.updateCookies  = false
            /// 연결 도메인의 쿠키 정보를 가져 옵니다.
            let cookies         = HTTPCookieStorage.shared.cookies(for: URL(string: AlamofireAgent.domainUrl )!)
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
        Slog("webView didFail")
        LoadingView.default.hide()
    }
    
    // page 로드 실패
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Slog("webView didFailProvisionalNavigation")
        LoadingView.default.hide()
    }
    
    
    
    //MARK: - ErrorViewDelegate
    func onErrorViewReload() {
        webView?.reload()
    }
    
    func onErrorViewClose() {
        if webView?.canGoBack ?? false {
            webView?.goBack()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension BaseWebViewController: WKUIDelegate {
    
    // MARK: - WKUIDelegate
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
}



//MARK: - WKScriptMessageHandler
extension BaseWebViewController: WKScriptMessageHandler {
    /**
     Web 에서 ScriptMessage 받는 메서드 입니다. ( J.D.H  VER : 1.0.0 )
     - Description : hybridscript, updateCookies 헨들러 이벤트를 받아 WebAPP 인터페이스를 처리 합니다.
     - Date : 2023.03.28
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Slog("wkwebview run javascript name = \(message.name) body = \(message.body)")
        /// 쿠키 업데이트 메세지 이벤트 입니다.
        if message.name == "\(SCRIPT_MESSAGE_HANDLER_TYPE.updateCookies)"
        {
            Slog("\(SCRIPT_MESSAGE_HANDLER_TYPE.updateCookies) : \(message.body)")
            /// 연결 도메인의 쿠키 정보를 가져 옵니다.
            let cookies         = HTTPCookieStorage.shared.cookies(for: URL(string: AlamofireAgent.domainUrl )!)
            /// 업데이할 쿠키 정보를 스크립트로 가져 옵니다.
            self.baseViewModel.getJSCookiesString(cookies: cookies).sink { script in
                self.webView!.evaluateJavaScript(script) { ( anyData , error) in
                    Slog("updateCookies anyData:\(anyData as Any)")
                    Slog("updateCookies error:\(error as Any)")
                    Slog("updateCookies script:\(script)")
                }
            }.store(in: &self.baseViewModel.cancellableSet)
            return
        }
        /// hybridscript 메세지 이벤트를 넘깁니다.
        messageHandler?.didReceiveMessage(message: message)
    }
}




