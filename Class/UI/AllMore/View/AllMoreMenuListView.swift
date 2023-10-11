//
//  AllMoreMenuListView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit
import Combine

/**
 전체 서비스의 메뉴별 ( 이번달 결제/적립부터 이용안내 까지 영역 ) 디스플레이 뷰어 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.07
*/
class AllMoreMenuListView: UIView {
    var cancellableSet = Set<AnyCancellable>()
    /// 화면 디스플레이에 사용될 모델 데이터 정보 입니다.
    var viewModel                           : AllMoreModel?
    /// 타이틀 뷰어 높이 입니다.
    @IBOutlet weak var titleViewHeight      : NSLayoutConstraint!
    /// 타이틀 문구 입니다.
    @IBOutlet weak var titleName            : UILabel!
    /// 리스트 뷰어 입니다.
    @IBOutlet weak var tableView            : UITableView!
    /// 리스트 뷰어 높이 입니다.
    @IBOutlet weak var tableViewHeight      : NSLayoutConstraint!
    /// 메뉴 리스트 뷰어 총 높이 정보 입니다.
    @IBOutlet weak var menuListViewHeight   : NSLayoutConstraint!
    /// 디스플레이할 메뉴 리스트 정보 입니다.
    var menus                               : [AllModeMenuListInfo]  = []
    
    
    // MARK: - instanceFromNib
    class func instanceFromNib() -> AllMoreMenuListView {
        return UINib(nibName: "AllMoreMenuListView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AllMoreMenuListView
    }
    
    
    // MARK: - 지원메서드 입니다.
    /**
     유저 상세 뷰어 초기화 메서드 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.25
     */
    func setDisplay( titleName : String = "", menus : [AllModeMenuListInfo] = [] ){
        /// 전체 높이 정보를 가집니다.
        var maxHeight = 16.0
        /// 타이틀 정보가 없는 경우 타이틀 디스플레이 영역을 제외 합니다.
        if titleName.count == 0
        {
            /// 최상단 여백 입니다.
            maxHeight                       += 8.0
            /// 타이틀 뷰어 히든 처리 합니다.
            self.titleViewHeight.constant   = 0
        }
        else
        {
            /// 최상단 여백 입니다.
            maxHeight                       += 8.0
            /// 타이틀 정보를 디스플레이 할 영역 입니다.
            maxHeight                       += 47.0
            /// 타이틀 정보를 추가 디스플레이 합니다.
            self.titleName.text             = titleName
            /// 타이틀 뷰어 높이를 추가 합니다.
            self.titleViewHeight.constant   = 47
        }
        
        /// 메뉴 리스트 카운트에 맞춰 리스트뷰 높이를 조정 합니다.
        maxHeight                           += Double(menus.count * 56)
        /// 하단 여백 높이를 추가 합니다.
        maxHeight                           += 8.0
        /// 화면 전체 높이를 설정 합니다.
        self.menuListViewHeight.constant    = maxHeight
        /// 디스플레이할 메뉴 정보를 받습니다.
        self.menus                          = menus
        
        /// 메뉴 리스트 정보 입니다.
        self.tableView.dataSource                = self
        self.tableView.delegate                  = self
        self.tableView.register(UINib(nibName: "AllMoreMenuListCell", bundle: nil), forCellReuseIdentifier: "AllMoreMenuListCell")
        /// 해더 간격을 0 으로 설정 합니다.
        if #available(iOS 15, *) { self.tableView.sectionHeaderTopPadding = 0 }
        self.tableView.reloadData()
    }
    
    
    
    func reloadDisplay( _ menus : [AllModeMenuListInfo] = [], viewModel : AllMoreModel? ){
        self.viewModel = viewModel
        /// 디스플레이할 메뉴 정보를 받습니다.
        self.menus     = menus
        self.tableView.reloadData()
    }
    
    
    /**
     모델 데이터 기준으로 화면에 추가 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.13
     - Parameters:
        - viewModel : 데이터 모델 입니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( _ viewModel : AllMoreModel? )
    {
        self.viewModel = viewModel
        self.tableView.reloadData()
    }
    

}

extension AllMoreMenuListView : UITableViewDelegate, UITableViewDataSource
{
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menus.count
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllMoreMenuListCell", for: indexPath) as! AllMoreMenuListCell
        let menuInfo : AllModeMenuListInfo = self.menus[indexPath.row]
        cell.menuTypeTitle = NC.S(self.titleName.text)
        cell.setDisplay(menuInfo, viewModel: self.viewModel)
        cell.backgroundColor = .clear
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}

