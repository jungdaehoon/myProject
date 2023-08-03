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

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        initControl()
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

        tfMnemonic.text = SharedDefaults.default.walletMnemonic.isValid == true ? SharedDefaults.default.walletMnemonic : "니모닉 정보가 없습니다."
        if(showNext){
            btnNext.setTitle("다음", for: .normal)
        }else{
            btnNext.setTitle("확인", for: .normal)
        }
    }

    
    /**
     데이터 세팅 입니다. ( J.D.H VER : 2.0.0 )
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
        self.popController(animated: true, animatedType: .down)
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
        if let completion = self.completion { completion(nil) }
        self.popController(animated: true, animatedType: .down)
    }
    
    @IBAction func onCopyMne(_ sender: Any) {
        let copyText = tfMnemonic.text ?? ""
        Slog("copy text = \(copyText)")
        UIPasteboard.general.string = copyText
        /// 앱 실드 비정상 처리 안내 팝업 입니다.
        CMAlertView().setAlertView(detailObject: "복사되었습니다" as AnyObject, cancelText: "확인") { event in
        }
    }
    
}

// MARK:// LoginViewControllerDelegate
extension ShowMnemonicViewController : CheckMnemonicVcDelegate  {
    
    func checkMnemonicResult(  _ controller : CheckMnemonicViewController , action: DelegateButtonAction, info: Any?) {
        switch action {
        
        // 닫기 버튼
        case .close:
            self.dismiss(animated: true, completion: {
                self.delegate?.showMnemonicResult(self, action: .close, info: nil)
                if let completion = self.completion { completion("true") }
                self.popController(animated: true, animatedType: .down)
            })
        default:
            ()
        }
        
    }
}
