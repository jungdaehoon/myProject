//
//  BottomAccountListView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/02.
//

import UIKit


/**
 하단 계좌 선택 뷰어  버튼 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.06.27
*/
enum BOTTOM_ACCOUNT_LIET_BTN_ACTION : Int {
    /// 계좌 리스트 종료 입니다.
    case close        = 10
    /// 계좌 추가 입니다.
    case add_account  = 11
}


/**
 이벤트 타입 입니다.    ( J.D.H VER : 2.0.0 )
 - Date: 2023.06.27
 */
enum BOTTOM_ACCOUNT_EVENT {
    /// 계좌 추가 이벤트 입니다.
    case add_account
    /// 계좌 선택 이벤트 입니다.
    case account( account : String? )
}


/**
 하단 계좌 선택 뷰어 입니다.   ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.05
 */
class BottomAccountListView: BaseView {

    let viewModel : BottomAccountModel = BottomAccountModel()
    /// 계좌 리스트 기본 높이 입니다.
    let ACCOUNT_DEFAULT_HEIGHT  = 102.0
    /// 계좌 리스트 기본 하단 위치 입니다.
    let ACCOUNT_DEFAULT_BOTTOM  = -24.0
    /// 계좌 기본 높이 입니다.
    let ACCOUNT_CELL_HEIGHT     = 64.0
    /// 이벤트 콜백 입니다.
    var completion                          : (( _ event : BOTTOM_ACCOUNT_EVENT ) -> Void )? = nil
    /// 계좌 리스트뷰 최하단 포지션 입니다.
    @IBOutlet weak var accountListViewBottom: NSLayoutConstraint!
    /// 계좌 리스트 뷰어 입니다.
    @IBOutlet weak var tableView            : UITableView!
    /// 계좌 리스트 최대 높이 입니다.
    @IBOutlet weak var tableViewHeight      : NSLayoutConstraint!
    /// 계좌 리스트 하단 포지션 입니다.
    @IBOutlet weak var tableViewBottom      : NSLayoutConstraint!
    /// 계좌 선택 인덱스 입니다.
    var accountSeleted                      : Int = 0
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        initBottomAccountListView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     계좌 리스트 뷰어 초기화 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.02
     */
    func initBottomAccountListView(){
        /// Xib 연결 합니다.
        self.commonInit()
        /// 메뉴 리스트 정보 입니다.
        self.tableView.dataSource                = self
        self.tableView.delegate                  = self
        self.tableView.register(UINib(nibName: "BottomAccountListTableViewCell", bundle: nil), forCellReuseIdentifier: "BottomAccountListTableViewCell")
        /// 해더 간격을 0 으로 설정 합니다.
        if #available(iOS 15, *) { self.tableView.sectionHeaderTopPadding = 0 }
      
        /// 계좌 리스트 기본 높이를 설정 합니다.
        self.tableViewHeight.constant       = 0
        /// 계좌 선택 리스트 뷰어 전체 높이를 아래로 이동 합니다.
        self.accountListViewBottom.constant = ACCOUNT_DEFAULT_HEIGHT + (ACCOUNT_CELL_HEIGHT * 5) * -1
    }


    /**
     계좌 정보를 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.02
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setDataDisplay(){
        self.isHidden = false
        /// 계좌 리스트 정보를 요청 합니다.
        self.viewModel.getAccountList().sink { result in
            
        } receiveValue: { model in
            if let _ = model {
                /// 바코드 결제 위치로 선택 배경을 이동합니다.
                UIView.animate(withDuration:0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: .curveEaseOut) { [self] in
                    let cell = self.viewModel.getAccountsHeight(model: model)
                    self.tableViewHeight.constant       = cell
                    self.accountListViewBottom.constant = ACCOUNT_DEFAULT_BOTTOM
                    self.layoutIfNeeded()
                    self.tableView.reloadData()
                } completion: { _ in
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.02
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show( completion : (( _ event : BOTTOM_ACCOUNT_EVENT ) -> Void )? = nil ) {
        self.completion = completion
        if let base = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                base.addSubview(self)
                /// 계좌 디스플레이 입니다.
                self.setDataDisplay()
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.02
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BottomAccountListView
                {
                    let view = $0 as! BottomAccountListView
                    /// 바코드 결제 위치로 선택 배경을 이동합니다.
                    UIView.animate(withDuration:0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut) { [self] in
                        self.tableViewHeight.constant       = 0
                        self.accountListViewBottom.constant = 0
                        self.tableViewBottom.constant       = 0
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
        if let type =  BOTTOM_ACCOUNT_LIET_BTN_ACTION(rawValue: (sender as AnyObject).tag)
        {
            switch type {
            case .add_account:
                if let event = self.completion {
                    event(.add_account)
                    self.isHidden = true
                }
                break
            case .close:
                self.hide()
                break
            }
        }
        
    }
}



// MARK: - UITableViewDelegate
extension BottomAccountListView : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = self.completion {
            if let response = self.viewModel.accountResponse,
               let accounts = response.list {
                /// 해당 계좌 메인 등록 요청 합니다.
                self.viewModel.setUpdateMainAccount(account: accounts[indexPath.row]).sink { result in
                    
                } receiveValue: { response in
                    event(.account(account: NC.S(accounts[indexPath.row].acc_no)))
                    /// 새로고침을 요청 합니다.
                    self.setDataDisplay()
                }.store(in: &self.viewModel.cancellableSet)
            }
        }
        /// 계좌 선택 여부를 체크 합니다.
        self.accountSeleted = indexPath.row
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if let response = self.viewModel.accountResponse,
           let accounts = response.list {
            /// 계좌 상세 정보에 따른 리스트 Height 값을 가져 옵니다.
            return self.viewModel.getAccountHeight(account: accounts[indexPath.row])
        }
        return ACCOUNT_CELL_HEIGHT
    }
}



// MARK: - UITableViewDataSource
extension BottomAccountListView : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let response = self.viewModel.accountResponse,
           let accounts = response.list {
            return accounts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomAccountListTableViewCell", for: indexPath) as! BottomAccountListTableViewCell
        cell.setDisplay(indexPath, viewModel: self.viewModel, seleted: self.accountSeleted == indexPath.row ? true : false )
        return cell
    }
    
    
}
