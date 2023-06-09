//
//  WalletViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/06/01.
//

import UIKit
import WebKit


class WalletViewController: BaseViewController {
    @IBOutlet weak var webDisplayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Slog("WalletViewController loadTabPageURL")
    }
    
    /**
     화면 새로고침 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.16
     */
    override func setDisplayData() {
        super.setDisplayData()
        Slog("WalletViewController setDisplayData loadTabPageURL")
        self.loadTabPageURL(WebPageConstants.URL_WALLET_HOME)
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



extension WalletViewController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode    = .mobile
        let request                         = navigationAction.request
        let optUrl                          = request.url
        let optUrlScheme                    = optUrl?.scheme
        guard let url = optUrl,
              let _ = optUrlScheme
            else {
                return decisionHandler(.cancel, preferences)
        }
        Slog("BenefitViewController url : \(url)")

        /// 해당 페이지에서 메인 URL 호출시 메인 탭으로 이동 합니다.
        if url.description.contains("matcs/main.do")
        {
            TabBarView.setReloadSeleted(pageIndex: 2)
            decisionHandler(.cancel, preferences)
            return
        }
        decisionHandler(.allow, preferences)
    }
}
