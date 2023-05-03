//
//  BottomAccountListView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/02.
//

import UIKit

/**
 하단 계좌 선택 뷰어 입니다.   ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.05
 */
class BottomAccountListView: UIView {

    /// 계좌 리스트뷰 최하단 포지션 입니다.
    @IBOutlet weak var accountListViewBottom: NSLayoutConstraint!
    /// 계좌 리스트 뷰어 입니다.
    @IBOutlet weak var tableView: UITableView!
    /// 계좌 리스트 최대 높이 입니다.
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    /// 선택 인덱스 입니다.
    var seletedIndex : Int = 0
    
    
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
     계좌 리스트 뷰어 초기화 입니다.
     - Date : 2023.05.02
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
                if $0 is BottomAccountListView
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



// MARK: - UITableViewDelegate
extension BottomAccountListView : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomAccountListTableViewCell", for: indexPath) as! BottomAccountListTableViewCell
        cell.seletedIcon.isHidden = true
        
        if self.seletedIndex == indexPath.row
        {
            cell.seletedIcon.isHidden = false
        }
        
        /*
        let termsinfo : TERMS_INFO  = self.termsList[indexPath.row]
        cell.titleName.text         = termsinfo.title!
        cell.selectionStyle         = .none
         */
        return cell
    }
    
    
}
