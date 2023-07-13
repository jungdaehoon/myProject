//
//  HybridOpenBankViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/29.
//

import UIKit
import WebKit

class HybridOpenBankViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    /// 이벤트를 넘깁니다.
    var completion                      : (( _ value : String ) -> Void )? = nil
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var okayButton: UIButton!
    
    static let OPENBANK_URL = "OPENBANK_URL"
    static let RESPONSE_URL = "temp.do"
    static let OPENBANK_AGREE_FAIL = 4444
    static let RESULT_CANCELED    = 0
    static let RESULT_OK          = -1
    
    var urlString: String!
    
    
    
    // MARK: - init
    /**
     전체 웹뷰 초기화 메서드 입니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.03.28
     - Parameters:
        - pageURL : 연결할 페이지 URL 입니다.
        - completion :  페이지 종료시 콜백 핸들러 입니다.
     - Throws: False
     - Returns:False
     */
    init( pageURL : String = "", completion : (( _ value : String ) -> Void )? = nil ) {
        super.init(nibName: nil, bundle: nil)
        /// 이벤트 정보를 리턴 하는 콜백입니다.
        self.completion         = completion
        self.urlString          = pageURL
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: urlString)!)
        self.webView.load(request)
    }

    
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    
        let url: String = webView.url?.absoluteString ?? ""
        if !url.isEmpty
        {
            Slog("didfinishi__URL::\(url)")
            if url.contains(HybridOpenBankViewController.RESPONSE_URL)
            {
                let rsp_code = self.getParameterFrom(url: url, param: "rsp_code")
                Slog("rsp_code::\(rsp_code)")
                if rsp_code == "0000"
                {
                    self.popController(animated: true, animatedType: .down) { firstViewController in
                        self.completion!("fnAccAggree(true);")
                    }
                }
                else
                {
                    CMAlertView().setAlertView(detailObject: "출금/조회 동의에 실패하였습니다." as AnyObject, cancelText: "확인") { event in
                        self.popController(animated: true, animatedType: .down) { firstViewController in
                            self.completion!("fnAccAggree(false);")
                        }
                    }                    
                }
            }
        }

    }
    
    
    func getParameterFrom(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
        
    @IBAction func onTappedBtn(_ sender: UIButton) {
        if sender.tag == 0
        {
            self.popController(animated: true, animatedType: .down) { firstViewController in
                self.completion!("fnAccAggree(false);")
            }
        }
    }
    
    @IBAction func onTappedClose(_ sender: UIButton) {
        self.popController(animated: true, animatedType: .down) { firstViewController in
            self.completion!("fnAccAggree(false);")
        }
    }
}
