//
//  TopUserInfoView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit

/**
 전체 상단 유저 안내뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.07
*/
class TopUserInfoView: UIView {

    var viewModel : AllMoreModel?
    /// 유저 프로필 이미지 입니다.
    @IBOutlet weak var profileImage: UIImageView!
    /// 유저 닉네임 정보 입니다.
    @IBOutlet weak var nickNameText : UILabel!
    /// 유저 프로필 이미지 왼쪽 기준 포지션 입니다.
    @IBOutlet weak var profileImageLeft: NSLayoutConstraint!
    
    
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
     - Date: 2023.03.08
     - Parameters:
        - model : 데이터 모델 정보를 받습니다.
     - Throws: False
     - Returns: False
     */
    func setDisplay( _ model : AllMoreModel )
    {
        /// 모델 정보를 연결 합니다.
        self.viewModel          = model
        if let result = model.allModeResponse!.result
        {
            /// 닉네임 정보를 디스플레이 합니다.
            self.nickNameText.text  = "\(result._nickname!)"
            /// NFT ID 정보가 있는지를 체크 합니다.
            if result._nft_id!.isValid
            {
                if let url = URL(string: WebPageConstants.baseURL + "/all/profileImage?userNo=" + result._user_no!) {
                    UIImageView.loadImage(from: url).sink { image in
                        if let profileImage = image {
                            /// 뷰어를 6각 형으로 변경 합니다.
                            self.profileImage.setHexagonImage()
                            self.profileImage.image         = profileImage
                            self.profileImageLeft.constant  = 12.0
                        }
                    }.store(in: &self.viewModel!.cancellableSet)
                }
            }
            else
            {
                /// 프로필 이미지를 다운로드 합니다.
                if result._user_img_url!.isValid,
                   let url = URL(string: result._user_img_url!)
                {
                    UIImageView.loadImage(from: url).sink { image in
                        if let profileImage = image {
                            self.profileImage.image = profileImage
                        }
                    }.store(in: &self.viewModel!.cancellableSet)
                }
            }
        }
    }
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.viewModel!.getAppMenuList(menuID: .ID_MYINFO).sink { url in
            self.setDisplayWebView(url + "?flag=2" )
        }.store(in: &self.viewModel!.cancellableSet)
    }
}
