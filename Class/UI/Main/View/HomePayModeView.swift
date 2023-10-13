//
//  HomePayModeView.swift
//  cereal
//
//  Created by OKPay on 2023/10/06.
//

import UIKit

/**
 탭바 결제 버튼 모드 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.20
 */
class HomePayModeView: UIView {

    /// 시작 로띠 뷰어를 추가합니다.
    var startHome : LottieAniView?
    /// 반복 로띠 뷰어를 추가합니다.
    var loopHome  : LottieAniView?
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initHomePayModeView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initHomePayModeView()
        /// 로띠 뷰어를 추가합니다.
        self.startHome = LottieAniView(frame: CGRect(origin: .zero, size: self.frame.size))
        self.startHome!.setAnimationView(name: "homeStart", loop: false, animationSpeed: 1.0)
        self.addSubview(self.startHome!)
        
        /// 로띠 뷰어를 추가합니다.
        self.loopHome  = LottieAniView(frame: CGRect(origin: .zero, size: self.frame.size))
        self.loopHome!.setAnimationView(name: "homeLoop", loop: true, animationSpeed: 1.0)
        self.addSubview(self.loopHome!)
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     홈 버튼 결제 타입 뷰어 초기화  입니다.  ( J.D.H VER : 2.0.2 )
     - Date: 2023.10.06
     */
    func initHomePayModeView(){
        self.commonInit()
    }
    
    
    /**
     홈 버튼 결제 타입 뷰어 시작 이미지 플레이  입니다.  ( J.D.H VER : 2.0.2 )
     - Date: 2023.10.06
     */
    func setStartPayMode(){
        self.startHome!.isHidden = false
        /// 로띠 뷰어를 추가합니다.
        self.startHome!.play(){ value in
            self.startHome!.isHidden = true
            self.loopHome!.isHidden  = false
            self.loopHome!.play()
        }
    }
    
    
    /**
     홈 버튼 결제 타입 뷰어 반복 중간 이미지 플레이  입니다.  ( J.D.H VER : 2.0.2 )
     - Date: 2023.10.06
     */
    func setStopPayMode() {
        self.startHome!.stop()
        self.loopHome!.stop()
        self.loopHome?.isHidden = true
    }
}
