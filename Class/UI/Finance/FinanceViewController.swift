//
//  FinanceViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit


/**
 금융 페이지 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.23
*/
class FinanceViewController: BaseViewController {

    @IBOutlet weak var webDisplayView: UIView!
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadMainURL(WebPageConstants.URL_FINANCE_MAIN)
    }

    
    
    // MARK: - 지원 메서드 입니다.
    /**
     전체 탭 페이지에 웹뷰를 히든 처리 하며 초기화 합니다.
     - Date : 2022.04.17
     */
    func setInitWebView()
    {
        /// 웹 화면 케시를 전부 삭제 합니다.
        self.messageHandler!.setWebViewClearCache()
        /// 화면을 초기화 합니다.
        self.webView!.load(URLRequest(url: URL(string: "about:blank")!))
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
