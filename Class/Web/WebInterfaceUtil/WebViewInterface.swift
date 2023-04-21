    //
    //  WebViewInterface.swift
    //  cereal
    //
    //  Created by srkang on 2018. 8. 1..
    //  Copyright © 2018년 srkang. All rights reserved.
    //
    
    import UIKit
    import WebKit
    
    
    class WebViewInterface  : NSObject {        
        static let COMMAND_CALL_HYBRID_POPUP    = "callHybridPopup" // Hybrid 웹뷰 팝업 요청
        static let COMMAND_CONFIRM_POPUP        = "confirmPopup" // 웹뷰 모달창에서 창을 닫으면서, 부모창에게 callback 데이터 JSON 전송
        static let COMMAND_CANCEL_POPUP         = "cancelPopup" // 웹뷰 모달창 닫기
        static let COMMAND_RECEIVE_POPUP        = "recieveParam" // 웹뷰 모달창에서 파라미터 가져오기
        
        static let COMMAND_CLEAR_CACHE          = "clearCache" // 웹뷰 캐시 지우기
        static let COMMAND_SHOW_WEBVIEW_POPUP   = "showWebviewPopup"
        //OJKIM ADDED START - 추가팝업창띄우기
        static let COMMAND_HYBRID_KIND_POPUP    = "callHybridKindPopup"
        //OJKIM ADDED END
        
        //JJBAE ADDED START
        static let COMMAND_HYBRID_LEVEL_POPUP = "showHybridLevelPopup"
        static let COMMAND_ADBRIX_USER_REGISTER = "userRegister"
        static let COMMAND_ADBRIX_ADD_EVENT = "addAdbrixEvent"
        static let COMMAND_ADBRIX_PURCHASE = "purchase"
        //JJBAE ADDED END
        
        static let COMMAND_HYBRID_OPENBANK_POPUP = "showOpenBankAccAgreePopup"
        static let COMMAND_HYBRID_CENGOLD_POPUP = "callHybridCenGoldPopup"
        static let COMMAND_HYBRID_CLOSE_POPUP = "closeHybridPopup"
        static let COMMAND_CHECK_WEB_LOGIN = "checkWebLogin"
        static let COMMAND_CALL_DEFAULT_BROWSER = "callDefaultBrowser"
        static let COMMAND_LAUNCH_EXTERNAL_APP = "launchExternalApp"
        
        weak var viewController : UIViewController!
        var command : Command!
        var resultCallback : ResultCallback!
        var byPass : Any? = nil
        
        init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
            super.init()
            self.command(viewController: viewController, command: command ,  result: result)
        }
        
        //
        init(viewController: UIViewController, command: Command,  byPass: Any ,  result: @escaping (HybridResult) -> ()) {
            self.byPass = byPass
            super.init()
            self.command(viewController: viewController, command: command ,  result: result)
            
        }
        
        deinit {
            log?.debug("WebViewInterface deinit")
        }
    }
    
    extension WebViewInterface : HybridInterface {
        
        func command(viewController: UIViewController, command: Command,  result: @escaping (HybridResult) -> ()) {
            
            self.viewController = viewController
            self.command = command
            self.resultCallback = result
            
            let action  = command[1] as! String
            let args    = command[2] as! [Any]
            
            if   action == WebViewInterface.COMMAND_CALL_HYBRID_POPUP {
                // Hybrid 웹뷰 팝업 요청
                let url     = args[0] as! String // URL
                let jsonArg = args[1]  as! String // JSON 파라미터
                
                let webViewController = UIStoryboard.storyboard(.main) .instantiateViewController() as CerealMainWebViewController
                // CerealMainWebViewController 는 원래 메인 웹뷰 화면용도로 사용했으나,
                // 모달형태로 그대로 띄울 수 있기 때문에, 구별하기 위해서 모달창 형태는 isMaster 를 false 로 한다.
                webViewController.isMaster = false
                if let parentWebViewController = viewController as? CerealMainWebViewController {
                    webViewController.delegate = parentWebViewController
                }
                
                viewController.present(webViewController, animated: true, completion: nil)
                // CerealMainWebViewController 의 subParameters에 url , json 파라미터를 넘겨준다.
                // CerealMainWebViewController 에서, URL 로딩하고, 웹뷰에서 하이브리드로 receiveParam 메소드를 호출하면,
                // json 파라미터 데이터를 넘겨준다.
                webViewController.subParameters = [
                    "url"       : url ,
                    "jsonArg"  : jsonArg ,
                ]
                
            } else if action == WebViewInterface.COMMAND_RECEIVE_POPUP  {
                // 웹뷰 모달창에서 파라미터 가져오기
                /*
                 callback(json) :  JSON 형태 리턴
                 
                 참고)  부모창에서 callHybridPopup 메소드에 전달했던 파라미터 json
                 */
                resultCallback(HybridResult.success(message: byPass! ))
                
            }   else if action == WebViewInterface.COMMAND_CONFIRM_POPUP  {
                // 웹뷰 모달창에서 창을 닫으면서, 부모창에게 callback 데이터 JSON 전송
                
                // JSON 데이터가 String 형태로  온 경우
                if let jsonArg = args[0]  as? String {
                    let data: Data = jsonArg.data(using: .utf8)!
                    
                    if let jsObj = try? JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) {
                        if let subWebViewController = viewController as? CerealMainWebViewController {
                            if let delegate = subWebViewController.delegate {
                                delegate.okSubWebViewController?(subWebViewController, callback: jsObj as? [String : Any])
                            }
                        }
                    }
                } else if let jsonArg = args[0]  as? [String:Any] {
                    // JSON 데이터가 Object 형태로  온 경우
                    if let subWebViewController = viewController as? CerealMainWebViewController {
                        if let delegate = subWebViewController.delegate {
                            delegate.okSubWebViewController?(subWebViewController, callback: jsonArg )
                        }
                    }
                } else {
                    // confirmPopup() 이런식으로 파라미터 안 넘겨줄 때, 더미 데이터로 리턴한다.
                    if let subWebViewController = viewController as? CerealMainWebViewController {
                        if let delegate = subWebViewController.delegate {
                            delegate.okSubWebViewController?(subWebViewController, callback: ["dummy1":"value1"] )
                        }
                    }
                }
            }  else if action == WebViewInterface.COMMAND_CANCEL_POPUP  {
                // 웹뷰 모달창 닫기
                if let subWebViewController = viewController as? CerealMainWebViewController {
                    if let delegate = subWebViewController.delegate {
                        delegate.okSubWebViewController?(subWebViewController, callback: nil)
                    }
                }
                
                
            } else if action == WebViewInterface.COMMAND_CLEAR_CACHE  {
                // 캐시 데이터 지우기
                //iOS9 이상일 경우 WKWebsiteDataStore 통해서 지운다 . 참고  https://stackoverflow.com/questions/27105094/how-to-remove-cache-in-wkwebview
                if #available(iOS 9.0, *)  {
                    let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
                    let date = NSDate(timeIntervalSince1970: 0)
                    
                    WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
                } else {
                    // iOS8 이하 일 경우 FileManager 와 URLCache 에 지운다.
                    var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
                    libraryPath += "/Cookies"
                    
                    do {
                        try FileManager.default.removeItem(atPath: libraryPath)
                    } catch {
                        log?.debug("error")
                    }
                    URLCache.shared.removeAllCachedResponses()
                }
            } else if action == WebViewInterface.COMMAND_SHOW_WEBVIEW_POPUP {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let url     = args[0] as! String // URL
                    let vc = WebViewController.init(nibName: "WebViewController", bundle: nil)
                    vc.url = url
                    viewController.present(vc, animated: true, completion: {
                    })
                }
                //OJKIM ADDED START - 추가팝업창띄우기
            } else if action == WebViewInterface.COMMAND_HYBRID_KIND_POPUP {

                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let url = args[0] as! String // URL
                    let jsonArgs = args[1] as! String

                    let hybridKindWebView = HybridKindWebView(url, jsonArgs)
                    hybridKindWebView.layer.borderColor = UIColor.darkGray.cgColor
                    hybridKindWebView.layer.borderWidth = 1
                    if #available(iOS 11.0, *) {
                        hybridKindWebView.frame = CGRect(x: viewController.view.safeAreaInsets.left,
                                                         y: viewController.view.safeAreaInsets.top,
                                                         width: viewController.view.bounds.size.width - viewController.view.safeAreaInsets.left - viewController.view.safeAreaInsets.right,
                                                         height: viewController.view.bounds.size.height - viewController.view.safeAreaInsets.top)
                    } else {
                        hybridKindWebView.frame = CGRect(x: viewController.view.bounds.origin.x,
                                                         y: viewController.view.bounds.origin.y + 20,
                                                         width: viewController.view.bounds.size.width,
                                                         height: viewController.view.bounds.size.height)
                    }
                    viewController.view.addSubview(hybridKindWebView)
                }
                //OJKIM ADDED END
               
            }else if action == WebViewInterface.COMMAND_CALL_DEFAULT_BROWSER
            {
                let url     = args[0] as! String
                
                if let subWebViewController = viewController as? CerealMainWebViewController
                {
                    subWebViewController.urlString = url
                }
                
                
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
//                    let url     = args[0] as! String // URL
                    
//                    let vc = WebViewController.init(nibName: "WebViewController", bundle: nil)
//                    vc.url = url
//                    viewController.present(vc, animated: true, completion: {
//                    })
//                }
                
            //JJBAE ADDED START
            }else if action == WebViewInterface.COMMAND_HYBRID_LEVEL_POPUP {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let message = args[0] as! String
                    let level = args[1] as! String
                    let colour = args[2] as! Int
                    let levelController = UIStoryboard.storyboard(.main).instantiateViewController() as AlertViewController
                    
                    levelController.message = message
                    levelController.level = level
                    levelController.colour = colour
                    levelController.modalPresentationStyle = .overFullScreen
                    viewController.present(levelController, animated: false, completion: {})
                }
            } else if action == WebViewInterface.COMMAND_ADBRIX_USER_REGISTER {
//                AdBrixRM.getInstance.commonSignUp(channel: AdBrixRM.AdBrixRmSignUpChannel.AdBrixRmSignUpGoogleChannel)
                
                //YUN ADDED Adjust
                let event = ADJEvent(eventToken: "h7a6bw");
                // Add callback parameters to this event.
                event?.addCallbackParameter("sign_channel", value: "UserId");
                Adjust.trackEvent(event);
                //YUN ADDED END Adjust
                
            } else if action == WebViewInterface.COMMAND_ADBRIX_ADD_EVENT {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let event = args[0] as! String
                    
                    //YUN ADDED START Adjust
//                    if event.contains("xhonjy")
//                    {
//                        AdBrixRM.getInstance.event(eventName: "sign_up_a")
//                    }
//                    else if  event.contains("yhmrfo")
//                    {
//                        AdBrixRM.getInstance.event(eventName: "sign_up_b")
//                    }
//                    else if event.contains("goebtm")
//                    {
//                        AdBrixRM.getInstance.event(eventName: "sign_up_c")
//                    }
//                    else if event.contains("mszafs")
//                    {
//                        AdBrixRM.getInstance.event(eventName: "sign_up_d")
//                    }
                  
                    let eventSetting = ADJEvent(eventToken: event)
                    Adjust.trackEvent(eventSetting)
                    //YUN ADDED END Adjust
                    
                }
            }
            else if action == WebViewInterface.COMMAND_ADBRIX_PURCHASE {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let orderId = args[0] as! String
                    let productId = args[1] as! String
                    let productName = args[2] as! String
                    let price = args[3] as! String
                    
//                    var productModelArrayList: Array = Array<Any>()
//                    
//                    let productModel = AdBrixRM.getInstance.createCommerceProductDataWithAttr(productId: productId, productName: productName, price: Double(price)!, quantity: 0, discount: 0.0, currencyString: "0", category: nil, productAttrsMap: nil)
//                    
//                    productModelArrayList.append(productModel)
//                    
//                    AdBrixRM.getInstance.commonPurchase(orderId: orderId, productInfo: productModelArrayList as! Array<AdBrixRmCommerceProductModel>, discount: 1.0, deliveryCharge: 0.00, paymentMethod: AdBrixRM.getInstance.convertPayment(AdBrixRM.AdbrixRmPaymentMethod.ETC.rawValue))
                    
                    
                    //YUN ADDED Adjust
                    let event = ADJEvent(eventToken: "sn34z7");
                    event?.addCallbackParameter("order_id", value: orderId)
                    event?.addCallbackParameter("product_id", value: productId)
                    event?.addCallbackParameter("product_name", value: productName)
                    event?.addCallbackParameter("price", value: price)
                    Adjust.trackEvent(event);
                    //YUN ADDED END Adjust
                    
                }
            }
            else if action == WebViewInterface.COMMAND_HYBRID_OPENBANK_POPUP
            {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    //yun
                    let vc = UIStoryboard.storyboard(.main).instantiateViewController() as HybridOpenBankViewController
                    vc.urlString = args[0] as? String
                    //                                    .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                   viewController.present(vc, animated: true)
                    
                }
            }
            else if action == WebViewInterface.COMMAND_HYBRID_CENGOLD_POPUP
            {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    //yun
                    let vc = UIStoryboard.storyboard(.main).instantiateViewController() as CenGoldViewController
                    vc.mUrlString = args[0] as! String //URL
                    vc.mParentCrealVC = viewController as? CerealMainWebViewController
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    viewController.present(nav, animated: true)
                    
                }
                
            }
            else if action == WebViewInterface.COMMAND_HYBRID_CLOSE_POPUP
            {
                if let subWebViewController = viewController as? CerealMainWebViewController {
                    if let delegate = subWebViewController.delegate {
                        delegate.okSubWebViewController?(subWebViewController, callback: ["GOLD":"value1"] )
                    }
                }
            }
            else if action == WebViewInterface.COMMAND_LAUNCH_EXTERNAL_APP
            {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let urlString     = args[0] as! String
                    
                    if let subWebViewController = viewController as? CerealMainWebViewController
                    {
                        let request = URLRequest(url:  URL(string: urlString)!)
                        subWebViewController.webView.load(request)
                    }
                }
            
            }
            //JJBAE ADDED END
        }
        
        func afterNotify(_ data : Any) {
            // CerealMainWebViewControllerDelegate 가 모달창 닫으면서, 처리 result 를 요청.
            if let stringData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
                if let dataString = String.init(data: stringData, encoding: .utf8) {
                    resultCallback(HybridResult.success(message: dataString))
                }
            }
            
            
        }
    }
    
/*
    //OJKIM ADDED START - 추가팝업창띄우기
    class HybridKindWebView : UIView {
        var titleTextView: UILabel!
        var kindWebView: WKWebView!
        var confirmButton: UIButton!
        var buttonLayout: UIView!
        var cancelButton: UIButton!
        var closeButton: UIButton!
        
        var __url: String!
        var __json: JSON!
        
        let SCRIPT_HANDLER_NAME = "hybridscript"
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        init(_ url: String!, _ jsonArgs: String!) {
            super.init(frame: CGRect.zero)
            
            __url = url
            do {
                __json = try JSON(data: jsonArgs.data(using: .utf8)!)
            } catch {
            }
            
            titleTextView = UILabel(frame: CGRect.zero)
            confirmButton = UIButton(frame: CGRect.zero)
            buttonLayout = UIView(frame: CGRect.zero)
            cancelButton = UIButton(frame: CGRect.zero)
            closeButton = UIButton(frame: CGRect.zero)
            
            titleTextView.backgroundColor = UIColor.white
            titleTextView.textAlignment = NSTextAlignment.center
            closeButton.setImage(UIImage(named: "btn_close"), for: UIControl.State.normal)
            buttonLayout.backgroundColor = UIColor.white
            confirmButton.setBackgroundImage(UIColor(hexString: "7d4bd2").createImageFromUIColor(), for: UIControl.State())
            confirmButton.setBackgroundImage(UIColor(hexString: "7ac612").createImageFromUIColor(), for: .highlighted)
            cancelButton.setBackgroundImage(UIColor(hexString: "7d4bd2").createImageFromUIColor(), for: UIControl.State())
            cancelButton.setBackgroundImage(UIColor(hexString: "7ac612").createImageFromUIColor(), for: .highlighted)
            confirmButton.setTitle("확인", for: UIControl.State.normal)
            cancelButton.setTitle("취소", for: UIControl.State.normal)
            
            let contentController = WKUserContentController()
            contentController.removeAllUserScripts()
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
  
            
            kindWebView = WKWebView(frame: CGRect.zero, configuration: config)
            //		kindWebView.uiDelegate = self
            //		kindWebView.navigationDelegate = self
            kindWebView.scrollView.showsHorizontalScrollIndicator = false
            
            addSubview(kindWebView)
            addSubview(titleTextView)
            addSubview(closeButton)
            addSubview(buttonLayout)
            buttonLayout.addSubview(confirmButton)
            buttonLayout.addSubview(cancelButton)
            
            closeButton.addTarget(self, action: #selector(onCloseClick(_:)), for: UIControl.Event.touchUpInside)
            cancelButton.addTarget(self, action: #selector(onCancelClick(_:)), for: UIControl.Event.touchUpInside)
            confirmButton.addTarget(self, action: #selector(onConfirmClick(_:)), for: UIControl.Event.touchUpInside)
            
            
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            var isShowTitle = false
            var isShowConfirmButton = false
            var isShowCancelButton = false
            if __json != nil {
                if __json["titleType"].stringValue == "1" {
                    isShowTitle = true
                    let jsonObject: JSON! = __json["parameter"]
                    if (jsonObject != nil) {
                        titleTextView.text = jsonObject["title"].stringValue
                    }
                }
                if __json["callType"].stringValue == "1" {
                    isShowConfirmButton = true
                    isShowCancelButton = true
                } else if __json["callType"].stringValue == "2" {
                    isShowConfirmButton = true
                } else {
                    isShowConfirmButton = false
                    isShowCancelButton = false
                }
                
            }
            var topY: CGFloat = 0
            var webHeight: CGFloat = 0
            if true == isShowTitle {
                titleTextView.isHidden = false
                titleTextView.frame = CGRect(0, 0, self.frame.width, 50)
                topY = 50
                webHeight = self.frame.height - 100
            } else {
                titleTextView.isHidden = true
                webHeight = self.frame.height - 50
            }
            closeButton.backgroundColor = UIColor(red: 0x00, green: 0x00, blue: 0x00, alpha: 0.2)
            closeButton.frame = CGRect(self.frame.width - 40, 10, 30, 30);
            if isShowConfirmButton == true && isShowCancelButton == true {
                cancelButton.isHidden = false
                confirmButton.isHidden = false
                buttonLayout.frame = CGRect(0, self.frame.height - 100, self.frame.width, 50)
                cancelButton.frame = CGRect(0, 0, (self.frame.width - 1) / 2, 50)
                confirmButton.frame = CGRect(((self.frame.width - 1) / 2) + 1, 0, (self.frame.width - 1) / 2, 50)
                webHeight -= 50
            } else if isShowConfirmButton == true {
                cancelButton.isHidden = true
                confirmButton.isHidden = false
                buttonLayout.frame = CGRect(0, self.frame.height - 100, self.frame.width, 50)
                confirmButton.frame = CGRect(0, 0, self.frame.width, 50)
                webHeight -= 50
            } else {
                cancelButton.isHidden = true
                confirmButton.isHidden = true
            }
            
            kindWebView.frame = CGRect(0, topY, self.frame.width, webHeight)
   
            kindWebView.load(URLRequest(url: URL(string: __url)!))

           
            
            //        backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        }
        
        @objc func onCloseClick(_ button: UIButton) {
            self.removeFromSuperview()
        }
        
        @objc func onCancelClick(_ button: UIButton) {
            onCloseClick(button)
        }
        
        @objc func onConfirmClick(_ button: UIButton) {
            let script = "fnAccAggree(false);"
            self.evaluateJS(script: script);
            
        }
        
        @objc func evaluateJS(script: String)
        {
            self.kindWebView.evaluateJavaScript(script) { ( anyData , error) in
                self.onCloseClick(self.confirmButton)
            }
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            if point.y > self.frame.height - 60 {
                onCloseClick(closeButton);
                return false
            } else {
                return true
            }
        }
        
    }
    
 */

