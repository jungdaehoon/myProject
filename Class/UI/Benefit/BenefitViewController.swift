//
//  BenefitViewController.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/14.
//

import UIKit

class BenefitViewController: BaseViewController {

    @IBOutlet weak var webDisplayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadMainURL(WebPageConstants.URL_BENEFIT_MAIN)
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
