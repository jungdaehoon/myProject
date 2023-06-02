//
//  GuideInfoViewCollectionViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/10.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit


/**
 가이드 셀별 페이지 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.24
*/
class GuideInfoViewCollectionViewCell: UICollectionViewCell {
    /// 이벤트를 넘깁니다.
    var completion                  : (( _ value : String ) -> Void )? = nil
    /// 타이틀 문구 입니다.
    @IBOutlet weak var titleText    : UILabel!
    /// 타이틀 문구 서브 입니다.
    @IBOutlet weak var titleSubText : UILabel!
    /// 안내 문구 입니다.
    @IBOutlet weak var subInfoText  : UILabel!
    /// 가이드 로띠 이미지 디스플레이 뷰어 입니다.
    @IBOutlet weak var aniImageView : UIView!
    /// 하단 시작 하기 버튼 입니다.
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setDisplay( _ index : Int, completion : (( _ value : String ) -> Void )? = nil )
    {
        self.completion             = completion
        self.bottomView.isHidden    = true
        switch index {
        case 0:
            self.titleText.text     = "언제 어디서나"
            self.titleSubText.text  = "간편한 송금"
            self.subInfoText.text   = "더 안전한 블록체인 기반 PAY!"
            
            break
        case 1:
            self.titleText.text     = "혜택 쌓이는"
            self.titleSubText.text  = "간편결제"
            self.subInfoText.text   = "쓰면 쓸수록 쌓이는 혜택!"
            
            break
        case 2:
            self.titleText.text     = "달달하고 짭짤한"
            self.titleSubText.text  = "앱테크"
            self.subInfoText.text   = "매일 달달하게 쌓이는 포인트!"
            break
        case 3:
            self.titleText.text     = "OK에서 누리는"
            self.titleSubText.text  = "NFT 세상"
            self.subInfoText.text   = "나만의 NFT 컬렉션!"
            self.bottomView.isHidden = false
            break
        default:
            break
        }
        self.layoutIfNeeded()
        Slog("self.frame : \(self.frame.size)")
        Slog("self.aniImageView.frame.size : \(self.aniImageView.frame.size)")
        /// 이전에 추가된 뷰어가 있다면 전부 삭제하고 추가합니다.
        for subView in self.aniImageView.subviews { subView.removeFromSuperview() }
        /// 로띠 뷰어를 추가합니다.
        let aniView = LottieAniView(frame: CGRect(origin: .zero, size: self.aniImageView.frame.size))
        aniView.setAnimationView(name: "guide_ani_\(index)", loop: true)
        self.aniImageView.addSubview(aniView)
        aniView.play()
    }
    
    @IBAction func btn_action(_ sender: Any) {
        self.completion!("EXIT")
    }
}
