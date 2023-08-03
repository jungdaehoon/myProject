//
//  WKWebView.swift
//  MyData
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import WebKit

extension WKWebView {
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    /**
     기본 URL 연결 지원 메서드 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.05.09
     - Parameters:
        - url : 연결할 URL 정보 입니다.
        - domainUrl : 기본 도메인 URL 정보 입니다.
        - httpMethod : HTTP 연결 타입 입니다. ( default : GET )
        - postData : HTTP 연결 타입이 POST 경우 데이터 입니다.
        - headerFields : HTTP 연결시 Header 정보 입니다.
     - Returns: False
     */
    func urlLoad( url : String,
                  domainUrl : String = WebPageConstants.baseURL,
                  httpMethod : String = "GET",
                  postData : String = "",
                  headerFields : [String:String] = [:] ){
        var  urlRequest         = URLRequest(url: URL(string: url)!)
        /// HTTP 타입 정보를 설정 합니다.
        urlRequest.httpMethod   = httpMethod
        // 쿠키 정보 셋팅
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: domainUrl )!)
        {
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
            if let value = cookieHeaders["Cookie"]
            {
                urlRequest.setValue(value, forHTTPHeaderField: "Cookie")
                Slog("cookie value:\(value)")
            }
        }
        
        ///POST 타입 일 경우 입니다.
        if httpMethod == "POST"
        {
            /// 바디 데이터를 추가합니다.
            urlRequest.httpBody = postData.data(using: .utf8)
            /// 헤더 정보를 추가 합니다.
            for (key,value) in headerFields
            {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let weblog = """
        _\n\n----------------------------- WebView Request Open -------------------------------
        [WebView Request Type]: \n\(httpMethod)
        [WebView Request Url]: \n\(urlRequest.url!.absoluteString)
        [WebView Load Request Header]: \n\(urlRequest.allHTTPHeaderFields!)
        [WebView Request Body]: \n\(postData)
        ----------------------------- WebView Request End --------------------------------
        _\n
        """
        Slog("\(weblog)", category: .network)
        load(urlRequest)
    }
    
    func urlLoad(urlStr: String) {
        guard let url = URL(string: urlStr) else {
            #if DEBUG
            //Toast.show("unsupported URL : \(urlStr)")
            #endif
            return
        }
        let request = URLRequest(url: url)
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
         
        //쿠키를 담을 배열 sharedCookies
        let sharedCookies: Array<HTTPCookie> = HTTPCookieStorage.shared.cookies(for: request.url!) ?? []
        let dispatchGroup = DispatchGroup()
         
        if sharedCookies.count > 0 {
            //sharedCookies에서 쿠키들을 뽑아내서 wkDataStore에 넣는다.
            for cookie in sharedCookies {
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                //wkDataStore를 configuration에 추가한다.
                self.configuration.websiteDataStore = wkDataStore
            }
        }
        load(request)
    }
    
    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
    
    func setCookie(_ domain: String, completion: @escaping () -> Void) {
        let properties: [String: String] = [
            "Version-Name": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0",
            "Version-Code": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0",
        ]
        
        let group = DispatchGroup()
        for property in properties {
            let cookieProperties: [HTTPCookiePropertyKey : Any] = [
                HTTPCookiePropertyKey.domain: domain,
                HTTPCookiePropertyKey.path: "/mydata",
                HTTPCookiePropertyKey.name: property.key,
                HTTPCookiePropertyKey.value: property.value
            ]
            
            group.enter()
            if let cookie = HTTPCookie(properties:cookieProperties) {
                self.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func callWebFunc(javascriptFunc: String) {
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                self.callAsyncJavaScript(javascriptFunc, in: WKFrameInfo.init(), in: .page)
            } else {
                self.evaluateJavaScript(javascriptFunc, completionHandler: { (result, error) in
                })
            }
            
        }
    }
    
    func callWebFunc(javascriptFunc: String, _ completion: @escaping ()->()) {
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                self.callAsyncJavaScript(javascriptFunc, in: WKFrameInfo.init(), in: .page, completionHandler: { result in
                    completion()
                })
            } else {
                self.evaluateJavaScript(javascriptFunc, completionHandler: { (result, error) in
                    completion()
                })
            }
            
        }
    }
    
    static func removeCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})                
                Slog("WKWebsiteDataStore record deleted: \(record)")
            }
        }
    }
    
    
    func clearHistory() {
        if self.canGoBack {
            self.go(to: self.backForwardList.backList.first!)
        }
    }
    
    
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.isOpaque, 0)
        let currentContentOffset    = scrollView.contentOffset
        let currentFrame            = scrollView.frame
        
        scrollView.contentOffset    = CGPoint.zero
        scrollView.frame            = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image                   = UIGraphicsGetImageFromCurrentImageContext()!
        scrollView.contentOffset    = currentContentOffset
        scrollView.frame            = currentFrame
        UIGraphicsEndImageContext()
        return image
    }
    
    
    public func swContentCapture(_ completionHandler:@escaping (_ capturedImage: UIImage?) -> Void) {
        
        self.isCapturing = true
        
        let offset = self.scrollView.contentOffset
        
        // Put a fake Cover of View
        let snapShotView = self.snapshotView(afterScreenUpdates: true)
        
        snapShotView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: (snapShotView?.frame.size.width)!, height: (snapShotView?.frame.size.height)!)
        //self.superview?.addSubview(snapShotView!)
        
        if self.frame.size.height < self.scrollView.contentSize.height {
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.frame.size.height)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.scrollView.contentOffset = CGPoint.zero
            
            self.swContentCaptureWithoutOffset({ [weak self] (capturedImage) -> Void in
                let strongSelf = self!
                
                strongSelf.scrollView.contentOffset = offset
                
                snapShotView?.removeFromSuperview()
                
                strongSelf.isCapturing = false
                
                completionHandler(capturedImage)
            })
        }
    }
    
    fileprivate func swContentCaptureWithoutOffset(_ completionHandler:@escaping (_ capturedImage: UIImage?) -> Void) {
        let containerView  = UIView(frame: self.bounds)
        
        let bakFrame     = self.frame
        let bakSuperView = self.superview
        let bakIndex     = self.superview?.subviews.firstIndex(of: self)
        
        // remove WebView from superview & put container view
        self.removeFromSuperview()
        containerView.addSubview(self)
        
        let totalSize = self.scrollView.contentSize
        
        // Divide
        let page       = floorf(Float( totalSize.height / containerView.bounds.height))
        
        self.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: self.scrollView.contentSize.height)

        UIGraphicsBeginImageContextWithOptions(totalSize, false, UIScreen.main.scale)
        
        self.swContentPageDraw(containerView, index: 0, maxIndex: Int(page), drawCallback: { [weak self] () -> Void in
            let strongSelf = self!
            
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Recover
            strongSelf.removeFromSuperview()
            bakSuperView?.insertSubview(strongSelf, at: bakIndex!)
            
            strongSelf.frame = bakFrame
            
            containerView.removeFromSuperview()
            
            completionHandler(capturedImage)
        })
    }
    
    fileprivate func swContentPageDraw (_ targetView: UIView, index: Int, maxIndex: Int, drawCallback: @escaping () -> Void) {
        
        // set up split frame of super view
        let splitFrame = CGRect(x: 0, y: CGFloat(index) * targetView.frame.size.height, width: targetView.bounds.size.width, height: targetView.frame.size.height)
        // set up webview frame
        var myFrame = self.frame
        myFrame.origin.y = -(CGFloat(index) * targetView.frame.size.height)
        self.frame = myFrame
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            targetView.drawHierarchy(in: splitFrame, afterScreenUpdates: true)
            
            if index < maxIndex {
                self.swContentPageDraw(targetView, index: index + 1, maxIndex: maxIndex, drawCallback: drawCallback)
            }else{
                drawCallback()
            }
        }
    }
    

    // Simulate People Action, all the `fixed` element will be repeate
    // SwContentCapture will capture all content without simulate people action, more perfect.
    public func swContentScrollCapture (_ completionHandler: @escaping (_ capturedImage: UIImage?) -> Void) {
        
        self.isCapturing = true
        
        // Put a fake Cover of View
        let snapShotView = self.snapshotView(afterScreenUpdates: true)
        snapShotView?.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: (snapShotView?.frame.size.width)!, height: (snapShotView?.frame.size.height)!)
        self.superview?.addSubview(snapShotView!)
        
        // Backup
        let bakOffset    = self.scrollView.contentOffset
        
        // Divide
        let page  = floorf(Float(self.scrollView.contentSize.height / self.bounds.height))
        
        UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, false, UIScreen.main.scale)
        
        self.swContentScrollPageDraw(0, maxIndex: Int(page), drawCallback: { [weak self] () -> Void in
            let strongSelf = self
            
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Recover
            strongSelf?.scrollView.setContentOffset(bakOffset, animated: false)
            snapShotView?.removeFromSuperview()
            
            strongSelf?.isCapturing = false
            
            completionHandler(capturedImage)
        })
        
    }
    
    fileprivate func swContentScrollPageDraw (_ index: Int, maxIndex: Int, drawCallback: @escaping () -> Void) {
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(index) * self.scrollView.frame.size.height), animated: false)
        let splitFrame = CGRect(x: 0, y: CGFloat(index) * self.scrollView.frame.size.height, width: bounds.size.width, height: bounds.size.height)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.drawHierarchy(in: splitFrame, afterScreenUpdates: true)
            
            if index < maxIndex {
                self.swContentScrollPageDraw(index + 1, maxIndex: maxIndex, drawCallback: drawCallback)
            }else{
                drawCallback()
            }
        }
    }
}
