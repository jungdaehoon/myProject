//
//  BottomAccountListTableViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/02.
//

import UIKit

/**
 하단 계좌 선택 뷰어 계좌 리스트 Cell  입니다.. ( J.D.H VER : 2.0.0 )
 - Date: 2023.06.27
*/
class BottomAccountListTableViewCell: UITableViewCell {

    /// 계좌 뷰어 입니다.
    @IBOutlet weak var accountView      : UIView!
    /// 제인증 계좌 정보 뷰어 입니다.
    @IBOutlet weak var reauthAccountView: UIView!
    /// 은행 아이콘 입니다.
    @IBOutlet weak var bankIcon         : UIImageView!
    /// 메인 계좌 체크 아이콘 입니다.
    @IBOutlet weak var mainAccountIcon  : UIImageView!
    /// 계좌 넘버 입니다.
    @IBOutlet weak var accountNum       : UILabel!
    /// 계좌 넘버 입니다.
    @IBOutlet weak var reauthAccountNum : UILabel!
    /// 선택 아이콘 입니다.
    @IBOutlet weak var seletedIcon      : UIImageView!
    /// 계좌 정보 입니다.
    var account : Account?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - 지원 메서드 입니다.
    /**
     계좌 정보를 받습니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.08.16
     - Parameters:
        - account : 계좌 정보 입니다.
        - viewModel : 뷰 모델을 받습니다.
        - seleted : 선택 여부 입니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( _ indexPath: IndexPath, viewModel : BottomAccountModel?, seleted : Bool = false )
    {
        if let response = viewModel!.accountResponse,
           let accounts = response.list {
            /// 계좌 정보 입니다.
            let account = accounts[indexPath.row]
            
            Slog("UIImageView.loadImage file 0 : \(AlamofireAgent.baseURL + account._bank_r_image_url!)")
            
            /// 뱅킹 이미지 입니다.
            if let url = URL(string: AlamofireAgent.baseURL + account._bank_r_image_url!) {
                self.bankIcon.load(url: url)
            }
            else
            {
                self.bankIcon.image = UIImage(named: "defaultBankLogo")
            }
            
            /// 메인계좌 아이콘 입니다.
            self.mainAccountIcon.isHidden   = account._main_yn == "Y" ? false : true
            /// 선택 아이콘 기본 false 로 설정 합니다.
            self.seletedIcon.isHidden       = account._main_yn == "Y" ? false : true
            /// 계좌 제인증 여부를 체크 합니다.
            if viewModel!.getAccountReauth(account: account)
            {
                self.reauthAccountView.isHidden = false
                /// 메인 계좌에 따른 폰트 정보 입니다.
                self.reauthAccountNum.font      = UIFont(name: account._main_yn == "Y" ? "Pretendard-Medium" : "Pretendard-Regular", size: 16.0)
                /// 메인 계좌에 따른 컬러 정보 입니다.
                self.reauthAccountNum.textColor = account._main_yn == "Y" ? UIColor(hex: 0x222222) : UIColor(hex: 0x666666)
                self.accountView.isHidden       = true
            }
            else
            {
                self.reauthAccountView.isHidden = true
                self.accountView.isHidden       = false
                /// 은행 정보 입니다.
                self.accountNum.text            = "\(account._bank_nm!) \(account._masking_acc_no!)"
                /// 메인 계좌에 따른 폰트 정보 입니다.
                self.accountNum.font            = UIFont(name: account._main_yn == "Y" ? "Pretendard-Medium" : "Pretendard-Regular", size: 16.0)
                /// 메인 계좌에 따른 컬러 정보 입니다.
                self.accountNum.textColor       = account._main_yn == "Y" ? UIColor(hex: 0x222222) : UIColor(hex: 0x666666)
            }
        }
    }
}
