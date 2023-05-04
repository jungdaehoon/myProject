//
//  BottomBankListCollectionViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/03.
//

import UIKit

/**
 제휴 은행 리스트 하단 뷰어의 각 은행 셀들 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.05.04
 */
class BottomBankListCollectionViewCell: UICollectionViewCell {
    /// 은행 아이콘 입니다.
    @IBOutlet weak var bankIcon     : UIImageView!
    /// 은행명 입니다.
    @IBOutlet weak var bankName     : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
