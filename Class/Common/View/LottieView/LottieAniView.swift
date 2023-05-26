//
//  LottieAniView.swift
//  MyData
//

import UIKit
import Lottie


/**
 Lottie.json 파일 디스플레이 뷰어입니다.
 - Date: 2023.05.04
 */
@objc class LottieAniView: UIView {
    /// 로띠 연결할 기본 뷰어 입니다.
    @objc var animationView = AnimationView(name: "loadingbar")
    
    
    
    // MARK: - init
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - override
    /**
     설정된 로띠 화면 layout 을 전체 화면으로 연결 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.05.04
     */
    override func updateConstraints() {
        self.addConstraintsToFit(animationView)
        super.updateConstraints()
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     연결할 기본 정보를 받아 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.05.04
     - Parameters:
        - name : 연결 할 파일명 입니다.
        - loop : 반복 여부를 받습니다. ( default : true )
     - Throws: False
     - Returns:False
     */
    @objc func setAnimationView(name: String, loop: Bool = true) {
        self.animationView                       = AnimationView(name: name)
        self.animationView.backgroundBehavior    = .forceFinish
        self.animationView.loopMode              = loop ? .loop : .playOnce
        self.animationView.animationSpeed        = 2.0
        self.addSubview(animationView)
    }
    
    
    /**
     플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.05.04
     - Parameters:
        - completion : 플레이 처리후 완료시 리턴 됩니다.
     - Throws: False
     - Returns:False
     */
    @objc func play( completion: LottieCompletionBlock? = nil ) {
        if !animationView.isAnimationPlaying {
            animationView.play(completion: completion)
        }
    }
    
    
    /**
     중단 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.05.04
     - Parameters:
        - completion : 플레이 처리후 완료시 리턴 됩니다.
     - Throws: False
     - Returns:False
     */
    @objc func stop() {
        if animationView.isAnimationPlaying {
            animationView.stop()
        }
    }
    
    
    
}
