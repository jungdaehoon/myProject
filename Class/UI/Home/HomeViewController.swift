//
//  HomeViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit
import WebKit

/**
 홈 페이지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.21
*/
class HomeViewController: BaseViewController {

    /// 웹 화면 디스플레이할 영역 뷰어 입니다.
    @IBOutlet weak var displayWebView: UIView!
    var loadEnabled : Bool = false
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 웹뷰를 초기화 합니다.
        self.initWebView( self.displayWebView, target: self )
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Slog("HomeViewController loadTabPageURL")
    }
    
    
    /**
     화면 새로고침 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.16
     */
    override func setDisplayData() {
        super.setDisplayData()
        Slog("HomeViewController setDisplayData loadTabPageURL")
        self.loadTabPageURL(WebPageConstants.URL_MAIN)
    }
}
