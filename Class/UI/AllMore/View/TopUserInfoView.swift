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
                            self.profileImage.image = profileImage
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
    
    func setHexagonImage(){
        print("self.profileImage.bounds : \(self.profileImage.bounds)")
        if let path = self.setHexagon(rect: CGRect(x: 5, y: 5, width: 70, height: 70)) {
            let drawinglayer                = CAShapeLayer()
            drawinglayer.frame              = CGRect(origin: CGPoint(x: 5, y: 5), size:.zero)
            drawinglayer.contentsScale      = UIScreen.main.scale
            drawinglayer.path               = path.cgPath
            
            drawinglayer.opacity            = 1.0
            drawinglayer.lineWidth          = 1.0
            drawinglayer.lineCap            = .round
            drawinglayer.lineJoin           = .round
            drawinglayer.lineDashPattern    = [3,3,3]
            drawinglayer.fillColor          = UIColor.clear.cgColor
            drawinglayer.strokeColor        = UIColor.red.cgColor
             
            //self.profileImage.layer.mask = drawinglayer
            self.profileImage.layer.addSublayer(drawinglayer)
        }
    }
    
    /**
     반 원형 도형을 생성하여 화면에 추가 합니다.
     - Date : 2022.08.08
     - parameters:
        - newPath : 도형 정보를 받습니다.
     - Throws:False
     - returns:Fasle
     */
    func setHexagon( rect : CGRect ) -> UIBezierPath?{
        let path = UIBezierPath(rect: rect)
        UIColor.lightGray.setFill()
        path.fill()
        path.close()

        let pentagonPath = UIBezierPath()

        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width/2, y: height/2)

        let sides = 6
        let cornerRadius: CGFloat = 1
        let rotationOffset = CGFloat(Double.pi / 2.0)
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides)
        let radius = (width + cornerRadius - (cos(theta) * cornerRadius)) / 2.0

        var angle = CGFloat(rotationOffset)

        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        pentagonPath.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        for _ in 0 ..< sides {
            angle += theta
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            pentagonPath.addLine(to: start)
            pentagonPath.addQuadCurve(to: end, controlPoint: tip)
        }

        var pathTransform  = CGAffineTransform.identity
        pathTransform = pathTransform.translatedBy(x: 0, y: -(rect.height-pentagonPath.bounds.height)/2)
        pentagonPath.apply(pathTransform)

        UIColor.black.set()
        pentagonPath.stroke()
        pentagonPath.close()
        return pentagonPath
    }
}
