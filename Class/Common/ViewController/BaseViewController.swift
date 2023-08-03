//
//  BaseViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/09.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit
import Combine


/**
 기본 베이스 컨트롤뷰 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
class BaseViewController: BaseWebViewController {
    var cancellableSet = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()        
        /// 앱 공용 키체인 정보가 nil 경우 최기화를 합니다.
        if SharedDefaults.getKeyChainCustItem() == nil
        {
            SharedDefaults.setKeyChainCustItem(KeyChainCustItem())
        }
    }
    

    /**
     화면 새로고침 디스플레이 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.05.15
     */
    func setDisplayData(){
        self.initWebPage()        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    class func instance(_ storyboardName: String) -> Self {
        func instantiateFromStoryboard<T: BaseViewController>(_ storyboardName: String) -> T {
            let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
            let identifier = String(describing: self)
            return storyboard.instantiateViewController(withIdentifier: identifier) as! T
        }
        return instantiateFromStoryboard(storyboardName)
    }
    
}
