//
//  BottomBankListCollectionViewCell.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/03.
//

import UIKit

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
