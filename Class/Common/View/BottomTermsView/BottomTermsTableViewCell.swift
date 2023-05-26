//
//  BottomTermsTableViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 하단 디스플레이 할 약관 동의 관련 안내 팝업에 리스트 셀 뷰어 입니다.
 - Date: 2023.03.15
 */
class BottomTermsTableViewCell: UITableViewCell {

    /// 타이틀명 입니다.
    @IBOutlet weak var titleName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
