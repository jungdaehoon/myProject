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
    /// 앱 시작시 이벤트 팝업 오픈 여부를 체크 합니다.
    var isEventPopup : Bool = false
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 웹뷰를 초기화 합니다.
        self.initWebView( self.displayWebView, target: self )
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Slog("HomeViewController loadTabPageURL")
        /// 이벤트 체크를 하지 않은 경우 입니다.
        if self.isEventPopup == false
        {            
            /// 로그인 상태 인지를 체크 합니다.
            if BaseViewModel.isLogin()
            {
                /// 이벤트 팝업 체크를 활성화 합니다.
                self.isEventPopup = true
                /// 앱 시작시 팝업 정보를 요청 합니다.
                if let eventInfos = BaseViewModel.appStartEventInfos(){
                    /// 이벤트 팝업을 오픈 합니다.
                    for eventInfo in eventInfos
                    {
                        /// 이벤트 디스플레이 날짜 정보를 체크 하여 날자 정보가 있는 경우에 해당 정보가 금일 보다 작으면 오픈 하지 않습니다.
                        if eventInfo._post_ed_dt!.isValid,
                           Date.getTodayString()! > eventInfo._post_ed_dt! { continue }
                        /// 팝업 타입 정보가 있는지를 체크 합니다.
                        if eventInfo._popup_kn!.isValid
                        {
                            /// 알림 팝업을 오픈 합니다.
                            let eventPop = AppStartEventPopup()
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
