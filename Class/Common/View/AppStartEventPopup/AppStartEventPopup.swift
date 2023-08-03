//
//  AppStartEventPopup.swift
//  cereal
//
//  Created by OKPay on 2023/07/12.
//

import UIKit



/**
 제로페이 페이지 버튼 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.07.13
*/
enum APPSTART_EVENT_BTN : Int {
    /// 페이지 종료 입니다.
    case close              = 0
    /// 하단 이벤트 뷰어 "오늘은 그만 보기" 선택시  입니다.
    case be_notToday        = 10
    /// 하단 이벤트 "확인" 선택시 입니다.
    case be_success         = 11
    /// 하단 이벤트 선택시 입니다.
    case be_eventChoice     = 12
    /// 시스템 안내 팝업  "오늘은 그만 보기" 선택시  입니다.
    case st_notToday        = 13
    /// 시스템 안내 팝업 "확인" 선택시 입니다.
    case st_success         = 14
    /// 중앙 이벤트  선택시  입니다.
    case ct_eventChoice     = 15
    /// 중앙 이벤트 팝업  "오늘은 그만 보기" 선택시  입니다.
    case ct_notToday        = 16
    /// 중앙 이벤트  팝업 "확인" 선택시 입니다.
    case ct_success         = 17
    
}


/**
 앱 시작시 이벤트 뷰어 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.07.12
 */
class AppStartEventPopup: BaseView {

    let viewModel  : AppStartEventViewModel = AppStartEventViewModel()
    /// 이벤트 모델 정보 입니다.
    var eventModel : eventInfo? = nil
    /// 이벤트 리턴 합니다.
    var completion : (( _ event : APPSTART_EVENT_BTN ) -> Void )? = nil
    /// 시스템 점검 안내 공지 팝업 입니다.
    @IBOutlet weak var sysytemPopView       : UIView!
    /// 시스템 안내 공지 타이틀 문구 입니다.
    @IBOutlet weak var sysytemViewTitle     : UILabel!
    /// 시스템 안내 공지 상세 문구 입니다.
    @IBOutlet weak var sysytemViewMessge    : UILabel!
    /// 중앙 이벤트 팝업 입니다.
    @IBOutlet weak var centerPopupView      : UIView!
    /// 중앙 이벤트 팝업 이미지 입니다.
    @IBOutlet weak var centerPopupImage     : UIImageView!
    /// 하단 이벤트 팝업 입니다.
    @IBOutlet weak var bottomPopupView      : UIView!
    /// 하단 이벤트 팝업 이미지 뷰어 입니다.
    @IBOutlet weak var bottomPopupImage     : UIImageView!
    /// 하단 이벤트 팝업 이미지 높이 가변에따른 높이 정보 입니다.
    @IBOutlet weak var bottomPopupImageHeight: NSLayoutConstraint!
    
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        initAppStartEventPopupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     앱 시작시 이벤트 뷰어 연결 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.12
     */
    func initAppStartEventPopupView( ){
        /// Xib 연결 합니다.
        self.commonInit()
    }

    
    /**
     앱 시작시 데이터 정보를 받아 상황별 이벤트 뷰어를 디스플레이 합니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.12
     - Parameters:
        - eventmModel  : 이벤트 데이터 모델 입니다.
     - Throws: False
     - Returns:False
     */
    func setDataDisplay( eventmModel : eventInfo? = nil, completion : (( _ event : APPSTART_EVENT_BTN ) -> Void )? = nil ) {
        if let model = eventmModel {            
            /// 모델 데이터를 추가합니다.
            self.eventModel = model
            /// 리턴 이벤트를 연결 합니다.
            self.completion = completion
            switch model._popup_kn
            {
                /// 중앙 이벤트 타입 입니다.
            case "0" :
                /// 오늘 다시보기 가능 여부를 체크 합니다.
                if Date.getTodayString()! > SharedDefaults.default.appStartCenterPopup {
                    self.setCenterEventDisplay(eventmModel: model)
                    self.show()
                }
                break
                /// 시스템. 공지 타입 입니다.
            case "1" :
                /// 오늘 다시보기 가능 여부를 체크 합니다.
                if Date.getTodayString()! > SharedDefaults.default.appStartSystemPopup {
                    self.setSystemPopup(eventmModel: model)
                    self.show()
                }
                break
                /// 하단 이벤트 타입 입니다.
            case "2" :
                /// 오늘 다시보기 가능 여부를 체크 합니다.
                if Date.getTodayString()! > SharedDefaults.default.appStartEventPopup {
                    self.setBottomEventDisplay(eventmModel: model)
                    self.show()
                }
                break
            default:break
            }
        }
    }
    
    
    /**
     시스템 팝업 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.12
     - Parameters:
        - eventmModel  : 이벤트 데이터 모델 입니다.
     - Throws: False
     - Returns:False
     */
    func setSystemPopup( eventmModel : eventInfo? = nil ) {
        if let model = eventmModel {
            /// 하단 이벤트 팝업 뷰어를 디스플레이 합니다.
            self.sysytemPopView.isHidden    = false
            /// 시스템 타이틀 정보를 추가합니다.
            self.sysytemViewTitle.text      = model._title
            /// 시스템 상세 정보를 추가 합니다.
            self.sysytemViewMessge.text     = model._note
        }
    }
    
    
    /**
     중앙 이벤트 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.12
     - Parameters:
        - eventmModel  : 이벤트 데이터 모델 입니다.
     - Throws: False
     - Returns:False
     */
    func setCenterEventDisplay( eventmModel : eventInfo? = nil ){
        if let model = eventmModel {
            /// 하단 이벤트 팝업 뷰어를 디스플레이 합니다.
            self.centerPopupView.isHidden = false
            /// 프로필 이미지를 다운로드 합니다.
            if model.img_url!.isValid,
               let url = URL(string: WebPageConstants.baseURL + model.img_url!)
            {
                UIImageView.loadImage(from: url).sink { image in
                    if let eventImage = image {
                        /// 하단 이벤트 팝업 이미지를 적용 합니다.
                        self.centerPopupImage.image = eventImage
                    }
                }.store(in: &self.viewModel.cancellableSet)
            }
        }
    }
    
    
    /**
     하단 이벤트 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.12
     - Parameters:
        - eventmModel  : 이벤트 데이터 모델 입니다.
     - Throws: False
     - Returns:False
     */
    func setBottomEventDisplay( eventmModel : eventInfo? = nil ){
        if let model = eventmModel {
            /// 하단 이벤트 팝업 뷰어를 디스플레이 합니다.
            self.bottomPopupView.isHidden = false
            /// 프로필 이미지를 다운로드 합니다.
            if model.img_url!.isValid,
               let url = URL(string: model.img_url!)
            {
                UIImageView.loadImage(from: url).sink { image in
                    if let eventImage = image {
                        /// 하단 이벤트 팝업 이미지를 적용 합니다.
                        self.bottomPopupImage.image = eventImage
                        /// 이미지 사이즈 기준으로 변경 할 사이즈 정보를 받습니다.
                        self.viewModel.getEventImageDisplaySize(image: eventImage, displaySize: self.bottomPopupImage.frame.size).sink { value in
                            if let resize = value {
                                /// 바코드 결제 위치로 선택 배경을 이동합니다.
                                UIView.animate(withDuration:0.3, delay: 0.0, options: .curveEaseOut) { [self] in
                                    self.bottomPopupImageHeight.constant = resize.height
                                    self.layoutIfNeeded()
                                } completion: { _ in
                                }
                            }
                        }.store(in: &self.viewModel.cancellableSet)
                        
                    }
                }.store(in: &self.viewModel.cancellableSet)
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.13
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show() {
        if let base = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.13
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is AppStartEventPopup
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    
    
    //MARK: - 버튼 이벤트 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  APPSTART_EVENT_BTN(rawValue: (sender as AnyObject).tag) {
            if self.eventModel != nil {
                switch type {
                case .be_eventChoice:
                    if let completion = self.completion {
                        completion(.be_eventChoice)
                    }
                    break
                case .be_notToday:
                    /// 오늘은 하단 이벤트 팝업 디스플레이 되지 않도록 날짜 정보를 추가합니다.
                    SharedDefaults.default.appStartEventPopup = Date.getTodayString()!
                    break
                case .be_success:
                    break
                case .close:
                    break
                case .st_notToday:
                    /// 오늘은 시스탬 팝업 디스플레이 되지 않도록 날짜 정보를 추가합니다.
                    SharedDefaults.default.appStartSystemPopup = Date.getTodayString()!
                    break
                case .st_success:
                    break
                case .ct_eventChoice:
                    if let completion = self.completion {
                        completion(.ct_eventChoice)
                    }
                    break
                case .ct_success:
                    break
                case .ct_notToday:
                    /// 오늘은 중앙 이벤트 팝업 디스플레이 되지 않도록 날짜 정보를 추가합니다.
                    SharedDefaults.default.appStartCenterPopup = Date.getTodayString()!
                    break
                }
            }
            self.hide()
        }
            
    }
}
