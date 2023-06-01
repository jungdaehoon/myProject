//
//  ShowMnemonicViewcontroller.swift
//  cereal
//
//  Created by develop wells on 2023/03/29.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation

protocol ShowMnemonicVcDelegate : AnyObject {
    func showMnemonicResult(  _ controller : ShowMnemonicViewController , action : DelegateButtonAction ,   info: Any?    ) -> Void
    
}

class ShowMnemonicViewController: UIViewController {

    
    weak var delegate : ShowMnemonicVcDelegate? = nil
    var mAlertView: UIAlertController?
    var showNext : Bool = false
    /// 이벤트를 넘깁니다.
    var completion  : (( _ value : Any? ) -> Void )? = nil
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tfMnemonic: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        Slog("Login deinit")
    }
    
    // 컨트롤 셋팅
    func initControl() {
        
        if let custItem = SharedDefaults.getKeyChainCustItem()
        {
            // 자동로그인 여부를 키체인에서 가져와서 셋팅
            if custItem.auto_login {
            }
        }
        
        var mnemonicTxt = WalletHelper.sharedInstance.getWalletMnemonicFromPref()
        if(mnemonicTxt == nil || mnemonicTxt?.count == 0){
            mnemonicTxt = "니모닉 정보가 없습니다."
        }
        tfMnemonic.text = mnemonicTxt
        if(showNext){
            btnNext.titleLabel?.text = "다음"
        }else{
            btnNext.titleLabel?.text = "확인"
        }
        
    }

    
    /**
     데이터 세팅 입니다.
     - Date: 2023.06.01
     - Parameters:
        - showNext : 다음 페이지 여부를 체크 합니다.
     - Throws: False
     - Returns:False
     */
    func setInitData( showNext : Bool = false , completion : (( _ value : Any? ) -> Void)? = nil ) {
        self.showNext   = showNext
        self.completion = completion
    }
    
    
    @IBAction func btnCopyClipAction(_ sender: Any) {
        self.delegate?.showMnemonicResult(self, action: .memberJoin, info: nil)
        if let completion = self.completion { completion("true") }
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        if(showNext){
            let storyboard                  = UIStoryboard(name: "Wallet", bundle: nil)
            let vc                          = storyboard.instantiateViewController(withIdentifier: "CheckMnemonicViewController") as! CheckMnemonicViewController
            vc.delegate                     = self
            vc.modalPresentationStyle       = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }else{
            onClose(sender)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.delegate?.showMnemonicResult(self, action: .close, info: nil)
        if let completion = self.completion { completion("true") }
    }
    
    @IBAction func onCopyMne(_ sender: Any) {
        let copyText = tfMnemonic.text ?? ""
        Slog("copy text = \(copyText)")
        UIPasteboard.general.string = copyText
        showAlertMessage(title:"",message:"복사되었습니다")
    }
    
}

// MARK:// LoginViewControllerDelegate
extension ShowMnemonicViewController : CheckMnemonicVcDelegate  {
    
    func checkMnemonicResult(  _ controller : CheckMnemonicViewController , action: DelegateButtonAction, info: Any?) {
        switch action {
        
        // 닫기 버튼
        case .close:
            self.dismiss(animated: true, completion: {
                self.onClose("")
            })
        default:
            ()
        }
        
    }
}
