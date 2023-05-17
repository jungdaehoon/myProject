//
//  BottomTermsView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 약관동의/취소 관련 버튼 이벤트 타입 입니다.
 - Date : 2023.03.15
 */
enum BTN_ACTION : Int {
    /// 동의 이벤트 입니다.
    case success    = 10
    /// 취소 이벤트 입니다.
    case cancel     = 11
}

/**
 약관동의 관련 데이터 정보를 관리합니다.
 - Date : 2023.03.15
 */
struct TERMS_INFO {
    /// 약관동의 타이틀 정보 입니다.
    var title : String?
    /// 약관동의 연결할 URL 정보 입니다.
    var url : String?
}


/**
 하단 디스플레이 할 약관 동의 관련 안내 팝업입니다.
 - Date : 2023.03.15
 */
class BottomTermsView: BaseView {

    
    /// 버튼 팝업 종료 이벤트를 넘깁니다.
    var completion                      : (( _ value : BTN_ACTION ) -> Void )? = nil
    /// 연결되는 타켓 뷰 컨트롤 입니다.
    var target                          : UIViewController?
    /// 약관 타이틀 문구 입니다.
    @IBOutlet weak var titleText        : UILabel!
    /// 약관들 문구 디스플레이 뷰어 입니다.
    @IBOutlet weak var tableView        : UITableView!
    /// 약관들 문구 디스플레이 뷰어 높이 입니다.
    @IBOutlet weak var tableViewHeight  : NSLayoutConstraint!
    /// 약관들 문구를 받습니다.
    var termsList                       : [TERMS_INFO]    =   []
    
    
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
     하단 약관동의 뷰어 입니다.
     - Date : 2023.03.15
     */
    func initBottomTermsView(){
        /// Xib 연결 합니다.
        self.commonInit()
        /// 메뉴 리스트 정보 입니다.
        tableView.dataSource                = self
        tableView.delegate                  = self
        tableView.register(UINib(nibName: "BottomTermsTableViewCell", bundle: nil), forCellReuseIdentifier: "BottomTermsTableViewCell")
        /// 해더 간격을 0 으로 설정 합니다.
        if #available(iOS 15, *) { tableView.sectionHeaderTopPadding = 0 }
        
    }

    
    /**
     안내 팝업 데이터를 설정 하고 디스플레이 합니다.
     - Date : 2023.03.15
     - Parameters:
        - target : 디스플레이할 타켓 뷰컨트롤러를 받습니다.
        - title : 팝업에 타이틀 영역 문구를 받습니다.
        - termsList : 약관동의할 리스트 정보를 받습니다.
        - completion : 동의/취소 여부에따른 버튼 이벤트를 리턴합니다.
     - Throws : False
     - returns :False
     */
    func setDisplay( target : UIViewController,  _ title : String,  termsList : [TERMS_INFO], completion : (( _ value : BTN_ACTION ) -> Void )? = nil )
    {
        self.target         = target
        self.titleText.text = title
        self.termsList      = termsList
        Slog("CGFloat(termsList.count * 16) : \(CGFloat(termsList.count * 32))")
        self.tableViewHeight.constant = CGFloat(termsList.count * 32)
        self.completion     = completion
        self.tableView.reloadData()
        self.show()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.
     - Date : 2023.03.15
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.
     - Date : 2023.03.15
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BottomTermsView
                {
                    $0.removeFromSuperview()
                }
            })
        }        
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btn : UIButton = sender as! UIButton
        /// 선택한 버튼 정보를 리턴 합니다.
        self.completion!(BTN_ACTION(rawValue: btn.tag)!)
        self.hide()
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
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomTermsTableViewCell", for: indexPath) as! BottomTermsTableViewCell
        
        let termsinfo : TERMS_INFO  = self.termsList[indexPath.row]
        cell.titleName.text         = termsinfo.title!
        cell.selectionStyle         = .none
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let termsinfo : TERMS_INFO  = self.termsList[indexPath.row]
        /// 전체 화면 웹뷰를 오픈 합니다.
        let viewController = FullWebViewController.init( titleBarType: 2, pageURL: termsinfo.url! ) { cbType in
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
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}


