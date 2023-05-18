//
//  FinanceViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit


/**
 금융 페이지 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.23
*/
class FinanceViewController: BaseViewController {

    @IBOutlet weak var webDisplayView: UIView!
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /**
     화면 새로고침 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     */
    override func setDisplayData() {
        super.setDisplayData()
        self.loadTabPageURL(WebPageConstants.URL_FINANCE_MAIN)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
