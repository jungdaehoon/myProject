//
//  BottomAccountListTableViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/02.
//

import UIKit

class BottomAccountListTableViewCell: UITableViewCell {

    /// 은행 아이콘 입니다.
    @IBOutlet weak var bankIcon     : UIImageView!
    /// 계좌 넘버 입니다.
    @IBOutlet weak var accountNum   : UILabel!
    /// 선택 아이콘 입니다.
    @IBOutlet weak var seletedIcon  : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
