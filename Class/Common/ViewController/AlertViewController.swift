//
//  AlertViewController.swift
//  cereal
//
//  Created by 아프로 on 28/10/2019.
//  Copyright © 2019 srkang. All rights reserved.
//

import UIKit

protocol AlertViewControllerDelegate : class {
    func alertViewControllerClosed(_ alertController: AlertViewController) -> Void
}
class AlertViewController : UIViewController {
    
    @IBOutlet weak var lbLevel: UILabel!
    @IBOutlet weak var ivMedal: UIImageView!
    @IBOutlet weak var lbContent: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    
    var message: String!
    var level: String!
    var colour: Int!
    
    weak var delegate : AlertViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbLevel.layer.zPosition = 1
        lbContent.numberOfLines = 2
        lbLevel.text = level
        lbContent.text = message
        
        switch colour {
            case 0:
                ivMedal.image = UIImage(named: "icon_medal_yellow.png")
                break
            case 1:
                ivMedal.image = UIImage(named: "icon_medal_orange.png")
                break
            case 2:
                ivMedal.image = UIImage(named:"icon_medal_green.png")
                break
            case 3:
                ivMedal.image = UIImage(named: "icon_medal_dark_green.png")
                break
            case 4:
                ivMedal.image = UIImage(named:"icon_medal_blue.png")
                break
            case 5:
                ivMedal.image = UIImage(named: "icon_medal_dark_blue.png")
                break
            case 6:
                ivMedal.image = UIImage(named:"icon_medal_pink.png")
                break
            case 7:
                ivMedal.image = UIImage(named: "icon_medal_dark_pink.png")
                break
            case 8:
                ivMedal.image = UIImage(named:"icon_medal_purple.png")
                break
            case 9:
                ivMedal.image = UIImage(named:"icon_medal_dark_purple.png")
                break
            default:
                ivMedal.image = UIImage(named: "icon_medal_yellow.png")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func onConfirmClick(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
