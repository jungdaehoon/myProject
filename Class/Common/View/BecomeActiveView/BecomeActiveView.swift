//
//  BecomeActiveView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/04.
//

import UIKit


/**
 백그라운드 및 현 화면 보이지 않도록 하는 로고 뷰어 입니다.   ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.05
 */
class BecomeActiveView: UIView {

    @IBOutlet weak var logoView: UIView!
    /// 로고 애니 효과 뷰어 입니다.
    var aniView : LottieAniView?
    /// 시스템 팝업 경우 로그 뷰어를 디스플레이 하지 않도록 체크 합니다.
    static var systemPopupEnabled : Bool = false
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        commonInit()
        /// 로띠 뷰어를 추가합니다.
        self.aniView = LottieAniView(frame: CGRect(origin: .zero, size: self.logoView.frame.size))
        self.aniView!.setAnimationView(name: "splash", loop: false, animationSpeed: 100.0)
        self.logoView.addSubview(self.aniView!)
        self.aniView!.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /**
     로고 뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        /// 시스템 팝업 경우 예외 처리 입니다.
        if BecomeActiveView.systemPopupEnabled { return }
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     로고 뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BecomeActiveView
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
}
