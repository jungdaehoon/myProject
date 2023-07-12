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
    
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 웹뷰를 초기화 합니다.
        self.initWebView( self.displayWebView, target: self )
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Slog("HomeViewController loadTabPageURL")
        
        /// 로그인 정보가 있는지를 체크합니다.
        if let login   = BaseViewModel.loginResponse,
           let islogin = login.islogin,
              islogin == true
        {
            /// 앱 시작시 팝업 !!
            if let start      = BaseViewModel.appStartResponse,
               let data       = start._data,
               let eventInfos = data.eventInfo,
               eventInfos.count > 0,
               let eventInfo  = eventInfos.first {
                /// 팝업 타입 입니다.
                if eventInfo._popup_kn!.isValid
                {
                    /// 알림 팝업을 오픈 합니다.
                    let eventPop = AppStartEventPopup()
                    eventPop.show()
                    /// 알림 팝업을 데이터에 맞춰 디스플레이 합니다.
                    eventPop.setDataDisplay(eventmModel: eventInfo) { event in
                        /// 이벤트 선택시입니다.
                        if event == .be_eventChoice
                        {
                            /// 이벤트 링크로 이동 합니다.
                            self.loadMainURL(eventInfo._link_url!)
                        }
                    }
                    
                }
            }
        }
        
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
