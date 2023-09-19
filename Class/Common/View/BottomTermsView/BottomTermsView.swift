//
//  BottomTermsView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 약관동의/취소 관련 버튼 이벤트 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.15
 */
enum BTN_ACTION : Int {
    /// 동의 이벤트 입니다.
    case success    = 10
    /// 취소 이벤트 입니다.
    case cancel     = 11
}


/**
 약관동의 관련 데이터 정보를 관리합니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.15
 */
struct TERMS_INFO {
    /// 약관동의 타이틀 정보 입니다.
    var title : String?
    /// 약관동의 연결할 URL 정보 입니다.
    var url : String?
    /// 체크박스 체크 여부 입니다.
    var check : Bool?
}


/**
 하단 디스플레이 할 약관 동의 관련 안내 팝업입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.15
 */
class BottomTermsView: BaseView {
    /// 버튼 팝업 종료 이벤트를 넘깁니다.
    var completion                      : (( _ value : BTN_ACTION ) -> Void )? = nil
    /// 연결되는 타켓 뷰 컨트롤 입니다.
    var target                          : UIViewController?
    /// 메인 디스플레이 뷰어 입니다.
    @IBOutlet weak var mainView         : UIView!
    /// 약관 타이틀 문구 입니다.
    @IBOutlet weak var titleText        : UILabel!
    /// 약관들 문구 디스플레이 뷰어 입니다.
    @IBOutlet weak var tableView        : UITableView!
    /// 약관들 문구 디스플레이 뷰어 높이 입니다.
    @IBOutlet weak var tableViewHeight  : NSLayoutConstraint!
    /// 약관 동의 팝업 전체 높이 입니다.
    @IBOutlet weak var termsHeight      : NSLayoutConstraint!
    /// 약관 동의 팝업 하단 포지션 입니다.
    @IBOutlet weak var termsBottom      : NSLayoutConstraint!
    /// 동의 버튼 입니다.
    @IBOutlet weak var successBtn       : UIButton!
    /// 배경 컬러 버튼 입니다.
    @IBOutlet weak var bgColorBtn       : UIButton!
    /// 약관들 문구를 받습니다.
    var termsList                       : [TERMS_INFO]    =   []
    /// 체크 박스 UI  활성화 여부 입니다.
    var isCheckUI                       : Bool            = false
    
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        initBottomTermsView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     하단 약관동의 뷰어 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.15
     */
    func initBottomTermsView(){
        /// Xib 연결 합니다.
        self.commonInit()
        /// 배경 애니 효과시 크기를 미리 설정하기 위해 합니다.
        self.bgColorBtn.frame           = UIScreen.main.bounds
        /// 애니 효과를 위해 기본. 사이즈를 미리 설정 합니다.
        self.mainView.frame.size.width  = UIScreen.main.bounds.size.width
        /// 메뉴 리스트 정보 입니다.
        tableView.dataSource            = self
        tableView.delegate              = self
        tableView.register(UINib(nibName: "BottomTermsTableViewCell", bundle: nil), forCellReuseIdentifier: "BottomTermsTableViewCell")
        /// 해더 간격을 0 으로 설정 합니다.
        if #available(iOS 15, *) { tableView.sectionHeaderTopPadding = 0 }
        
    }

    
    /**
     안내 팝업 데이터를 설정 하고 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.15
     - Parameters:
        - target : 디스플레이할 타켓 뷰컨트롤러를 받습니다.
        - title : 팝업에 타이틀 영역 문구를 받습니다.
        - termsList : 약관동의할 리스트 정보를 받습니다.
        - completion : 동의/취소 여부에따른 버튼 이벤트를 리턴합니다.
        - isCheckUI : 체크 박스 UI  모드 여부 입니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( target : UIViewController,
                     _ title : String,
                     termsList : [TERMS_INFO],
                     isCheckUI : Bool = false,
                     completion : (( _ value : BTN_ACTION ) -> Void )? = nil )
    {
        self.target                     = target
        self.titleText.text             = title
        self.isCheckUI                  = isCheckUI
        self.successBtn.backgroundColor = self.isCheckUI == true ? UIColor(hex: 0xe1e1e1) : .OKColor
        self.successBtn.setTitleColor(self.isCheckUI == true ? UIColor(hex: 0xbbbbbb) : .white, for: .normal)
        self.termsList                  = termsList
        self.tableViewHeight.constant = CGFloat(termsList.count * (self.isCheckUI == true ? 42 : 32))
        self.completion     = completion
        self.tableView.reloadData()
        self.show()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.15
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                self.alpha = 0.0
                base.addSubview(self)
                /// 바코드 결제 위치로 선택 배경을 이동합니다.
                UIView.animate(withDuration:0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: .curveEaseOut) { [self] in
                    self.termsBottom.constant = 0
                    self.alpha = 1.0
                    self.layoutIfNeeded()
                } completion: { _ in
                    
                }
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.15
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BottomTermsView
                {
                    let view = $0 as! BottomTermsView
                    /// 바코드 결제 위치로 선택 배경을 이동합니다.
                    UIView.animate(withDuration:0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut) { [self] in
                        self.termsBottom.constant -= self.termsHeight.constant
                        self.alpha = 0.0
                        self.layoutIfNeeded()
                    } completion: { _ in
                        view.removeFromSuperview()
                    }
                }
            })
        }        
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btnTag = BTN_ACTION.init(rawValue: (sender as! UIButton).tag)
        switch btnTag {
        case .success:
            if self.isCheckUI
            {
                if self.successBtn.backgroundColor == .OKColor
                {
                    /// 선택한 버튼 정보를 리턴 합니다.
                    self.completion!(btnTag!)
                    self.hide()
                }
            }
            else
            {
                /// 선택한 버튼 정보를 리턴 합니다.
                self.completion!(btnTag!)
                self.hide()
            }
            break
        case .cancel:
            /// 선택한 버튼 정보를 리턴 합니다.
            self.completion!(btnTag!)
            self.hide()
            break        
        default:break
        }
        
        
    }
    
}



extension BottomTermsView : UITableViewDelegate, UITableViewDataSource
{
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.termsList.count
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.isCheckUI == true ? 42 : 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "BottomTermsTableViewCell", for: indexPath) as! BottomTermsTableViewCell
        var terms = self.termsList[indexPath.row]
        /// 약관 리스트 셀 정보를 디스플레이 합니다.
        cell.setDisplay( isCheckUI: self.isCheckUI, termInfo: self.termsList[indexPath.row]) { value in
            switch value {
                /// 체크박스 선택시 입니다.
            case .check:
                cell.checkBoxBtn.isSelected   = !cell.checkBoxBtn.isSelected
                terms.check                   = cell.checkBoxBtn.isSelected
                self.termsList[indexPath.row] = terms
                /// 약관 동의 체크가 전부 선택 된 경우 입니다.
                if self.termsList.allSatisfy({ $0.check == true })
                {
                    self.successBtn.backgroundColor = .OKColor
                    self.successBtn.setTitleColor(.white, for: .normal)
                }
                else
                {
                    self.successBtn.backgroundColor = UIColor(hex: 0xe1e1e1)
                    self.successBtn.setTitleColor(UIColor(hex: 0xbbbbbb), for: .normal)
                }
                break
                /// 약관 정보 선택시 입니다.
            case .terms:
                /// 전체 화면 웹뷰를 오픈 합니다.
                let viewController = FullWebViewController.init( titleBarType: 2, pageURL: terms.url! ) { cbType in
                    switch cbType {
                    case .pageClose:
                        self.isHidden = false
                        return
                    default:
                        break
                    }
                }
                self.isHidden = true
                /// 연결된 컨트롤러 확인 합니다.
                if let controller = self.target
                {
                    /// 약관 동의 페이지를 이동 합니다.
                    controller.pushController(viewController, animated: true, animatedType: .up)
                }
                break
            }
        }
        cell.selectionStyle         = .none
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
}


