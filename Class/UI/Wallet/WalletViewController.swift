//
//  WalletViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/06/01.
//

import UIKit

class WalletViewController: BaseViewController {
    @IBOutlet weak var webDisplayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Slog("WalletViewController loadTabPageURL")
    }
    
    /**
     화면 새로고침 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.16
     */
    override func setDisplayData() {
        Slog("WalletViewController setDisplayData loadTabPageURL")
        self.loadTabPageURL(WebPageConstants.URL_WALLET_HOME)
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
