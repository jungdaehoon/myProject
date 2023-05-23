//
//  LoadingView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/05.
//

import UIKit


/**
 로딩 뷰어 입니다.   ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.17
 */
class LoadingView: UIView {
    /// 최대 로딩 타임 입니다.
    private let LOADING_MAX_TIME            = 10.0
    /// 로딩 디스플레이 뷰어 입니다.
    @IBOutlet weak var loadingView  : UIImageView!
    /// 로딩중 이미지를 체크 합니다.
    var isLoading                   : Bool = false
    /// 로딩 로띠 애니 이미지를 처리 합니다.
    var aniView                     : LottieAniView?
    /// 로딩 타이머 입니다.
    var loadingTimer                : Timer?
    
    
    static var `default`: LoadingView = {
        let defaults = LoadingView()
        return defaults
    }()
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        self.setLoadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    //MARK: - 지원 메서드 입니다.
    /**
     로딩 애니효과를 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.17
     */
    func setLoadingView(){
        commonInit()
        /// 로띠 뷰어를 추가합니다.
        self.aniView = LottieAniView(frame: CGRect(origin: .zero, size: self.loadingView.frame.size))
        self.aniView!.setAnimationView(name: "loadingbar", loop: true)
        self.loadingView.addSubview(self.aniView!)
    }
    
    
    /**
     로딩 최대 타임 종료시 호출 하여 로딩바 히든 처리 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.17
     */
    @objc func timerAction() {
        self.hide()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.17
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        /// 로그인 중에 추가 로그인 요청을 하지 않습니다.
        if self.isLoading { return }
        if let base = base {
            DispatchQueue.main.async {
                self.isLoading      = true
                self.loadingTimer   = Timer.scheduledTimer(timeInterval: self.LOADING_MAX_TIME,
                                             target: self, selector: #selector(self.timerAction),
                                             userInfo: nil,
                                             repeats: false)
                self.aniView!.play()
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.05
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        /// 로딩중이 아닌 경우 히든 처리시 리턴 합니다.
        if !self.isLoading { return }
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            self.isLoading = false
            self.aniView!.stop()
            if self.loadingTimer != nil
            {
                self.loadingTimer!.invalidate()
                self.loadingTimer = nil
            }
            _ = base!.subviews.map({
                if $0 is LoadingView
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    

}
