//
//  OKZeroPayCardView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/28.
//

import UIKit


/**
 제로페이 결제 가능 카드 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.04.28
 */
class OKZeroPayCardView: UIView {

    @IBOutlet weak var cardBGColor: UILabel!
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
