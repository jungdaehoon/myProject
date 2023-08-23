//
//  BottomTermsTableViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 리스트 선택 액션  타입 입니다. ( J.D.H VER : 2.0.2 )
 - Date: 2023.08.22
 */
enum CELL_BTN_ACTION : Int {
    /// 체크 박스 선택 액션 입니다.
    case check  = 10
    /// 약관 선택 액션 입니다.
    case terms  = 11
}

/**
 하단 디스플레이 할 약관 동의 관련 안내 팝업에 리스트 셀 뷰어 입니다. ( J.D.H VER : 2.0.2 )
 - Date: 2023.08.21
 */
class BottomTermsTableViewCell: UITableViewCell {

    /// 일반 텍스트 형태의 인포 뷰어 입니다.
    @IBOutlet weak var textInfoView     : UIView!
    /// 일반 텍스트 모드의 타이틀 정보 입니다.
    @IBOutlet weak var textInfoTitle    : UILabel!
    /// 체크 박스 형태의 인포 뷰어 입니다.
    @IBOutlet weak var checkBoxView     : UIView!
    /// 체크 박스 형태의 버튼 입니다.
    @IBOutlet weak var checkBoxBtn      : UIButton!
    /// 체크 박스 형태의 타이틀 정보 입니다.
    @IBOutlet weak var checkBoxTitle    : UILabel!
    /// 버튼 이벤트를 넘깁니다.
    var completion                      : (( _ value : CELL_BTN_ACTION ) -> Void )? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     안내 팝업 데이터를 설정 하고 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.15
     - Parameters:
        - isCheckUI : 체크 박스 UI  모드 여부 입니다.
        - termInfo : ui 디스플레이할 약관동의 정보 읍니다.
        - completion : 버튼 이벤트 입니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( isCheckUI : Bool = false, termInfo : TERMS_INFO, completion : (( _ value : CELL_BTN_ACTION ) -> Void )? = nil ){
        if isCheckUI == true
        {
            self.textInfoView.isHidden = true
            self.checkBoxView.isHidden = false
            self.checkBoxTitle.text    = termInfo.title!
        }
        else
        {
            self.textInfoView.isHidden = false
            self.checkBoxView.isHidden = true
            self.textInfoTitle.text    = termInfo.title!
        }
        self.completion = completion
    }
    
    
    //MARK: - 버튼 이벤트 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btn     = sender as! UIButton
        if let completion = self.completion {
            completion(CELL_BTN_ACTION.init(rawValue: btn.tag)!)
        }
        
        
    }
    
}
