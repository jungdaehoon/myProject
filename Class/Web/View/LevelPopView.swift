//
//  LevelPopView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/29.
//

import UIKit


/**
 레벨 팝업 입니다.   ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.29
 */
class LevelPopView: BaseView {

    /// 레벨 문구 입니다.
    @IBOutlet weak var levelText    : UILabel!
    /// 메달 이미지 입니다.
    @IBOutlet weak var medalImg     : UIImageView!
    /// 상세 문구 입니다.
    @IBOutlet weak var contentText  : UILabel!
   
    
    
    //MARK: - Init
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setLevelPopView( params : [Any] ){
        /// 안내 팝업 문구 입니다.
        let message = params[0] as! String
        /// 레벨 문구 입니다.
        let level   = params[1] as! String
        /// 디스플레이할 컬러 인덱스 입니다.
        let colour  = params[2] as! Int
        
        self.levelText.layer.zPosition  = 1
        self.levelText.text             = message
        self.contentText.text           = message
        self.medalImg.image             = UIImage(named: "icon_medal_\(colour).png")
        self.show()
        
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
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
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        DispatchQueue.main.async {
            _ = self.subviews.map({
                $0.removeFromSuperview()
            })
            self.removeFromSuperview()
        }
    }
    
    @IBAction func btn_action(_ sender: Any) {
        self.hide()
    }
}
