//
//  TopUserInfoView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit

/**
 전체 상단 유저 안내뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
*/
class TopUserInfoView: UIView {

    var viewModel : AllMoreModel?
    /// 유저 프로필 이미지 입니다.
    @IBOutlet weak var profileImage: UIImageView!
    /// 유저 레벨 정보 입니다.
    @IBOutlet weak var levelText    : UILabel!
    /// 유저 닉네임 정보 입니다.
    @IBOutlet weak var nickNameText : UILabel!
    
    
    // MARK: - instanceFromNib
    class func instanceFromNib() -> TopUserInfoView {
        return UINib(nibName: "TopUserInfoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopUserInfoView
    }
    
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
     
    
    // MARK: - 지원 메서드 입니다.
    /**
     데이터 기준으로 유저 정보를 디스플레이 합니다 ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.08
     - Parameters:
        - model : 데이터 모델 정보를 받습니다.
     - Throws : False
     - returns : False
     */
    func setDisplay( _ model : AllMoreModel )
    {
        /// 모델 정보를 연결 합니다.
        self.viewModel          = model
        if let result = model.allModeResponse!.result
        {
            /// 레벨 정보를 디스플레이 합니다.
            self.levelText.text     = "Level \(result._user_level!)"
            /// 닉네임 정보를 디스플레이 합니다.
            self.nickNameText.text  = "\(result._nickname!)"
            
            /// 프로필 이미지를 다운로드 합니다.
            let url = URL(string: result._user_img_url!)
            UIImageView.loadImage(from: url!).sink { image in
                if let profileImage = image {
                    self.profileImage.image = profileImage
                }
            }.store(in: &self.viewModel!.cancellableSet)
             
        }
        
        
    }
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        
        self.viewModel!.getAppMenuList(menuID: .ID_MYINFO).sink { url in
            self.setDisplayWebView(url + "?flag=2" )
        }.store(in: &self.viewModel!.cancellableSet)
    }
    
    
}
