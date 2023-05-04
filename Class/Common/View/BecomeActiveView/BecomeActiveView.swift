//
//  BecomeActiveView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/04.
//

import UIKit


/**
 백그라운드 및 현 화면 보이지 않도록 하는 로고 뷰어 입니다.   ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.05
 */
class BecomeActiveView: UIView {

    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /**
     로고 뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.05
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     로고 뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.05
     - Parameters:False
     - Throws : False
     - returns :False
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
