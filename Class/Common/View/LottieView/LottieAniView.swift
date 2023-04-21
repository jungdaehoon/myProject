//
//  LottieAniView.swift
//  MyData
//

import UIKit
import Lottie

@objc
class LottieAniView: UIView {
    
    @objc var animationView = AnimationView(name: "indicator")
    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setAnimationView(name: String, loop: Bool = true) {
        animationView = AnimationView(name: name)
        self.addSubview(animationView)
        animationView.backgroundBehavior = .forceFinish
        animationView.loopMode = loop ? .loop : .playOnce
        animationView.animationSpeed = 2.0 //추후 검토후, 수정요청시 변경예정 : 20220510 by itHan
    }
    
    @objc func aspectRatio() -> CGFloat {
        return (animationView.animation?.bounds.size.width ?? 0) / (animationView.animation?.bounds.size.height ?? 1)
    }
    
    override func updateConstraints() {
        
        self.addConstraintsToFit(animationView)
        
        super.updateConstraints()
    }
    
    @objc func play( completion: LottieCompletionBlock? = nil ) {
        if !animationView.isAnimationPlaying {
            animationView.play(completion: completion)
        }
    }
    @objc func stop() {
        if animationView.isAnimationPlaying {
            animationView.stop()
        }
    }
    
}
