//
//  BottomBankListView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/03.
//

import UIKit


/**
 제휴 은행 리스트 하단 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.05.04
 */
class BottomBankListView: UIView {

    /// 은행 리스트 뷰어의 최하단 위치 값입니다.
    @IBOutlet weak var bankListViewBottom: NSLayoutConstraint!
    /// 은행 리스트 입니다.
    @IBOutlet weak var collectionView: UICollectionView!
    /// 계좌 등록 상단 그라데이션 배경 입니다.
    @IBOutlet weak var accountTopGB: UILabel!
    /// 화면에 그려질 은행들 사이즈를 가집니다.
    var collectionCellSize : CGSize  = CGSize(width: 108, height: 96)
    
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        initBottomAccountListView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - 해당도 기준으로 화면 디스플레이 입니다.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let interval                    =  24.0 + 24.0 + 18.0
        let width                       = (UIScreen.main.bounds.size.width - interval) / 3
        self.collectionCellSize.width   = width
        self.collectionCellSize.height  = 96.0
    }
    
    
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     계좌 리스트 뷰어 초기화 입니다.
     - Date : 2023.05.02
     */
    func initBottomAccountListView(){
        /// Xib 연결 합니다.
        self.commonInit()
        // 가이드 디스플레이 뷰어 셀 설정 입니다.
        let nipName                             = UINib(nibName: "BottomBankListCollectionViewCell", bundle:nil)
        self.collectionView!.register(nipName, forCellWithReuseIdentifier: "BottomBankListCollectionViewCell")
    }


    /**
     뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.02
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show() {
        if let base = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.02
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BottomBankListView
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.hide()
    }
}



// MARK: - UICollectionViewDelegate extension
extension BottomBankListView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int { return 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 4 }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){}
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : BottomBankListCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomBankListCollectionViewCell", for: indexPath) as! BottomBankListCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionCellSize
    }
    
    
}


