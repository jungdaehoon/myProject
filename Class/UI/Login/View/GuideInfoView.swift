//
//  GuideInfoView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/10.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 가이드 안내 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.24
*/
class GuideInfoView: UIView {
    /// 시작 안내 뷰어 입니다.
    @IBOutlet weak var startView                : UIView!
    @IBOutlet weak var bottomView               : UIView!
    /// 하단 뷰어에 상단 그라데이션 컬러 영역 입니다.
    @IBOutlet weak var bottomTopColor           : UIView!
    /// 카드 배경 컬러 영역입니다.
    @IBOutlet weak var cardBgColor              : UIView!
    /// 카드 전체 뷰어 입니다.
    @IBOutlet weak var cardView                 : UIView!
    /// 하단 카드 올리는 화살표 뷰어 입니다.
    @IBOutlet weak var cardUpArrow              : UIView!
    /// 카드뷰 하단 포지션 입니다.
    @IBOutlet weak var cardViewBottom           : NSLayoutConstraint!
    /// 기본 Y 좌표 위치 값을 -24 로 진행 합니다.
    let CARD_BOTTOM_DEFAULT_Y                   : CGFloat = 16
    /// 기본 Y 좌표 위치 값을 -24 로 진행 합니다.
    var CARD_TOP_DEFAULT_Y                      : CGFloat = -24
    /// 카드 움직이는 위치 정보를 가집니다.
    var cardIngPostionY                         : CGFloat!
    
    
    /// 디스플레이 하는 전체 화면 입니다.
    @IBOutlet weak var displayView              : UIView!
    /// 디스플레이 전체 화면의 상단 포인트 입니다.
    @IBOutlet weak var displayViewTop           : NSLayoutConstraint!
    /// 이벤트를 넘깁니다.
    var completion                              : (( _ value : Bool ) -> Void )? = nil
    /// 총 가이드 좌우 디스플레이 페이지 입니다.
    @IBOutlet weak var collectionView           : UICollectionView!
    /// 페이지별 카운트 컨트롤러 입니다.
    @IBOutlet weak var pageControl              : UIPageControl!
    
    
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initGuideInfo()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initGuideInfo()
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     접근 권한 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.07
     */
    func initGuideInfo(){
        /// Xib 연결 합니다.
        self.commonInit()
        /// 가이드 디스플레이 뷰어 셀 설정 입니다.
        let nipName                             = UINib(nibName: "GuideInfoViewCollectionViewCell", bundle:nil)
        self.collectionView?.register(nipName, forCellWithReuseIdentifier: "GuideInfoViewCollectionViewCell")
        
        self.displayView.alpha                  = 0.0
        self.displayViewTop.constant            = UIScreen.main.bounds.size.height
        
        let gestrue = UIPanGestureRecognizer.init(target: self, action: #selector(self.gestureRecognizer(_ :)))
        self.bottomView.addGestureRecognizer(gestrue)
    }
    
    
    /**
     가이드 디스플레이를 시작 하며 버튼 이벤트를 연결 합니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.24
     - Parameters:
        - animation :
        - completion : 가이드 뷰어의 시작하기 이벤트를 넘기는 이벤트를 받습니다.
     - Throws: False
     - Returns:False
     */
    func setOpenView( animation : Bool = true,  completion : (( _ value : Bool ) -> Void )? = nil ){
        Slog("self.frame : \(self.frame)")
        self.completion = completion
        self.setAniDisplay( animation: false)
    }
    
    
    /**
     하단 카드 올리는 화살표 애니 이미지 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.24
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setLottieView(){
        /// 로딩중 뷰어를 설정 합니다.
        let aniView = LottieAniView(frame: CGRect(origin: .zero, size: self.cardUpArrow.frame.size))
        aniView.setAnimationView(name: "guide_up", loop: true)
        self.cardUpArrow.addSubview(aniView)
        aniView.play()
    }
    
    
    /**
     애니 효과로 디스플레이 합니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.24
     - Parameters:
        - animation : 애니 효과를 활성화 할지 여부를 받습니다.
     - Throws: False
     - Returns:False
     */
    func setAniDisplay( animation : Bool = true ){
        self.isHidden   = false
        UIView.animate(withDuration: animation == true ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut) {
            self.displayView.alpha          = 1.0
            self.displayViewTop.constant    = 0.0
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    
    /**
     애니 효과로 종료 합니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.24
     - Parameters:
        - animation : 애니 효과를 활성화 할지 여부를 받습니다.
     - Throws: False
     - Returns:False
     */
    func setAniClose( animation : Bool = true )
    {        
        UIView.animate(withDuration: animation == true ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut) {
            self.displayView.alpha          = 0.0
            self.displayViewTop.constant    = UIScreen.main.bounds.size.height
            self.layoutIfNeeded()
        } completion: { _ in
            self.setZeroPage()
            self.isHidden       = true
        }
    }
    
    
    /**
     가이드 디스플레이 순서를 초기화 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.29
     - Parameters:
        - animation : 애니 효과를 활성화 할지 여부를 받습니다. ( 기본 : false )
     - Throws: False
     - Returns:False
     */
    func setZeroPage( animation : Bool = false )
    {
        self.pageControl.currentPage  = 0
        self.collectionView.setContentOffset(.zero, animated: animation )
    }
    
    
    // MARK: - UIPanGestureRecognizer
    @objc func gestureRecognizer(_ gesture : UIPanGestureRecognizer){
        let positions      : CGPoint = gesture.location(in: gesture.view)
        var ingPosition    : CGFloat = 0.0
        
        if( gesture.state == .began )
        {
            /// 현 위치 값을 저장 합니다.
            self.cardIngPostionY = positions.y
            Slog("began : \(self.cardIngPostionY!)")
        }
        else if( gesture.state == .changed )
        {
            /// 시작 부터 현 이동한 위치 값을 체크 합니다.
            ingPosition                         = (self.cardIngPostionY - positions.y) + CARD_BOTTOM_DEFAULT_Y
            /// 카드 위치를 아래로 내리지 못하도록 합니다.
            if ingPosition < CARD_BOTTOM_DEFAULT_Y { return }
            /// 기본 위치 값에 이동한 위치값을 추가 합니다.
            self.cardViewBottom.constant        = ingPosition
            Slog("changed  : \(ingPosition)")
            /// 카드 전체 높이 기준 3/2 수준으로 올라가는 경우 입니다.
            if ingPosition > (( self.bottomView.frame.size.height - CARD_BOTTOM_DEFAULT_Y )/3) * 2
            {
                /// 페이지 히든 처리 합니다.
                self.cardView.isUserInteractionEnabled = false                
                UIView.animate(withDuration: 0.3) {
                    if self.startView.alpha != 0.0
                    {
                        Slog("밀어넣기!!!!")
                        self.startView.alpha = 0.0
                        BaseViewModel.setGAEvent(page: "인트로",area: "앱소개",label: "밀어넣기")
                    }
                    self.layoutIfNeeded()
                }
            }
        }
        else if(gesture.state == .ended )
        {
            Slog("ended!")
            /// 시작 부터 현 이동한 위치 값을 체크 합니다.
            ingPosition                         = (self.cardIngPostionY - positions.y) + CARD_BOTTOM_DEFAULT_Y
            Slog("ended! : \(ingPosition)")
            /// 카드 위치를 아래로 내리지 못하도록 합니다.
            if ingPosition < CARD_BOTTOM_DEFAULT_Y { return }
            /// 카드 전체 높이 기준 2/1 수준으로 올라가는 경우 입니다.
            if ingPosition > (( self.bottomView.frame.size.height - CARD_BOTTOM_DEFAULT_Y )/3) * 2
            {
                /// 페이지 히든 처리 합니다.
                self.cardView.isUserInteractionEnabled = false
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                    self.collectionView.reloadData()
                    self.startView.alpha = 0.0

                }
                return
            }
            else
            {
                /// 카드를 원위치 합니다.
                self.cardViewBottom.constant = CARD_BOTTOM_DEFAULT_Y
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
     
    
    // MARK: - 화면 디스플레이 영역 입니다.
    override func draw(_ rect: CGRect) {
        Slog("rect : \(rect)")
        self.bottomTopColor.setGradientDownTop(starColor: UIColor(hex: 0x000000,alpha: 0.0), endColor: UIColor(hex: 0x000000,alpha: 0.2))
        self.cardBgColor.setGradientDownTop(starColor: UIColor(hex: 0xFD9200,alpha: 1.0), endColor: UIColor(hex: 0xFF5000,alpha: 0.5))
        self.setLottieView()
        self.collectionView.reloadData()
    }
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        BaseViewModel.setGAEvent(page: "인트로",area: "앱소개",label: "건너뛰기")
        /// 가이드에서 앱 시작하기로 넘어감을 넘깁니다.
        self.completion!(true)
    }
}



// MARK: - UICollectionViewDelegate extension
extension GuideInfoView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int { return 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 4 }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){}
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : GuideInfoViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideInfoViewCollectionViewCell", for: indexPath) as! GuideInfoViewCollectionViewCell
        /// 현 위치 셀 ui 를 디스플레이 합니다.
        cell.setDisplay(indexPath.row) { value in
            if value == "EXIT"
            {
                /// 가이드에서 앱 시작하기로 넘어감을 넘깁니다.
                self.completion!(true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}


extension GuideInfoView : UIScrollViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /// 현 위치 정보를 디스플레이 합니다.
        let page                        = Int(targetContentOffset.pointee.x / self.frame.width)
        self.pageControl.currentPage    = page
        let gaNames:[String] = ["간편한 송금","간편결제","앱테크","NFT 세상"]
        BaseViewModel.setGAEvent(page: "인트로",area: "앱소개",label: gaNames[self.pageControl.currentPage])
    }
}
