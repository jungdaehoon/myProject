//
//  QRBarCodeFullViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/17.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit


/**
 제로페이 코드 전체화면 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
*/
class QRBarCodeFullViewController: UIViewController {

    var viewModel                       : OKZeroViewModel = OKZeroViewModel()
    /// QR/바코드 이미지를 받습니다.
    var codeImage                       : UIImage?
    /// 디스플레이 코드 스케일 정보 값을 가집니다.
    var scale                           : CGFloat = 1.0
    /// QR/바코드 이미지를 화면에 디스플레이 합니다.
    @IBOutlet weak var codeImageView    : UIImageView!
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        /// 코드 이미지를 추가합니다.
        self.codeImageView.image                = self.codeImage!
        /// QR 라인 컬러를 설정 합니다.
        self.codeImageView.tintColor            = .black
        /// QR 배경 컬러를 설정 합니다.
        self.codeImageView.backgroundColor      = .white
        
        /// 이미지 확대 스케일을 설정 합니다.
        let updateScale                         = CGAffineTransform(scaleX: self.scale, y: self.scale)
        /// 이미지를 회전 합니다.
        self.codeImageView.transform            = updateScale.concatenating(self.codeImageView.transform.rotated(by: .pi/2))
        
    }


    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true, completion: {
        })
    }

}
