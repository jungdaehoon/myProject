//
//  PermissionInfoView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/10.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 접근권한 안내 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.24
*/
class PermissionInfoView: UIView {

    @IBOutlet weak var infoViewTop      : NSLayoutConstraint!
    /// 권안 안내 뷰어 입니다.
    @IBOutlet weak var infoView         : UIView!
    /// 접근 권한 안내 타이틀 문구 입니다.
    @IBOutlet weak var titleText        : UILabel!
    /// 이벤트를 넘깁니다.
    var completion                      : (( _ value : Bool ) -> Void )? = nil
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initPermissionInfo()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initPermissionInfo()
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     접근 권한 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.07
     */
    func initPermissionInfo(){
        /// Xib 연결 합니다.
        self.commonInit()
        
        let attributedString = NSMutableAttributedString(string: "OKpay를 이용하시려면\n접근권한을 꼭 허용해주세요", attributes: [
          .font: UIFont(name: "Pretendard-SemiBold", size: 20.0)!,
          .foregroundColor: UIColor(white: 34.0 / 255.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 1.0, green: 83.0 / 255.0, blue: 0.0, alpha: 1.0), range: NSRange(location: 22, length: 2))
        
        self.titleText.attributedText   = attributedString
        self.infoViewTop.constant       = UIScreen.main.bounds.size.height
        self.infoView.alpha             = 0.0
    }
    
           
    /**
     애니 효과로 디스플레이 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.24
     - Parameters:
        - animation : 애니 효과를 활성화 할지 여부를 받습니다.
     - Throws : False
     - returns :False
     */
    func setAniDisplay( animation : Bool = true )
    {
        let topMinHeight    : CGFloat = 3.0
        let maxHeight       : CGFloat = 865
        self.isHidden = false
        UIView.animate(withDuration: animation == true ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut) {
            /// 전체 화면이 권한 안내 팝업보다 클경우 입니다.
            if UIScreen.main.bounds.size.height > maxHeight
            {
                /// 권한안내 팝업을 최대 높이까지 디스플레이 가능한 높이를 설정 합니다.
                self.infoViewTop.constant = UIScreen.main.bounds.size.height - maxHeight
            }
            /// 전체 화면이 권한 안내 팝업보다 작을 경우 입니다.
            else
            {
                /// 최대 가능한 높이 위치로 이동합니다.
                self.infoViewTop.constant = topMinHeight
            }
            self.infoView.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
    
    
    /**
     애니 효과로 종료 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.24
     - Parameters:
        - animation : 애니 효과를 활성화 할지 여부를 받습니다.
     - Throws : False
     - returns :False
     */
    func setAniClose( enabeld : Bool )
    {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.infoViewTop.constant = UIScreen.main.bounds.size.height
            self.infoView.alpha = 0.0
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden       = true
            self.completion!(enabeld)
        }
    }
    
    
    /**
     접근권한 뷰어를 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.10
     - Parameters:
        - completion : 접근 권한 뷰어에 이벤트를 넘깁니다.
     - Throws : False
     - returns :False
     */
    func setOpenView( animation : Bool = true, completion : (( _ value : Bool ) -> Void )? = nil ){
        
        self.setAniDisplay( animation: animation )
        self.completion = completion
    }
    

    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btn : UIButton  = sender as! UIButton
        switch btn.tag {
        case 10:
            self.setAniClose( enabeld: false )
            break
        case 11:
            /// 접근권한 확인 이벤트를 넘깁니다.
            self.setAniClose( enabeld: true)
            break
        default:
            break
        }
    }
}
