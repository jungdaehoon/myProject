//
//  RestoreWalletViewController.swift
//  cereal
//
//  Created by develop wells on 2023/03/30.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation


protocol RestoreWalletVcDelegate : class {
    func restoreWalletResult(  _ controller : RestoreWalletViewController , action : DelegateButtonAction ,   info: Any?    ) -> Void
    
}

class RestoreWalletViewController: UIViewController {

    
    weak var delegate : RestoreWalletVcDelegate? = nil
    var mAlertView: UIAlertController?
    var encInfo : String = ""
    var preAddr : String = ""
    
    @IBOutlet weak var tfMnemonic: TextFieldWithPadding!
    
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
        tfMnemonic.delegate = self
    }

    
    @IBAction func onConfirm(_ sender: Any) {
        self.clickConfirm()
    }
    
    @IBAction func onLostMnemonic(_ sender: Any) {
        showConfirmLostMnemonic()
    }
    @IBAction func onClose(_ sender: Any) {
        self.delegate?.restoreWalletResult(self, action: .close, info: nil)
    }
    
    func showConfirmLostMnemonic(){
        let alert = UIAlertController(title: "복구구문을 잃어버리셨나요?",
                                      message:  "복구 구문을 메모 하지 않은 경우나 분실한 경우는 관리자를 통한 요청으로 복구가 가능합니다.\n\n 복구 요청을 하시겠습니까?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel) { _ in
//            Slog("취소처리")
        })

        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default,
                                      handler: { action in
            self.delegate?.restoreWalletResult(self, action: .close, info: "recovery-admin")
        }))
        
        self.present(alert,  animated: true, completion: nil)
    }
    
    func showAlertCheckMnemonic(){
        let alert = UIAlertController(title: "",
                                      message:  "복구 구문 확인이 틀렸습니다. 복구 구문을 다시 한번 확인 해 주세요.",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default,
                                      handler: { action in
        }))
        
        self.present(alert,  animated: true, completion: nil)
    }
    func getMneAryFromStr(_ mnemonicStr : String ) -> Array<String>?{
        let mne2 = mnemonicStr.replacingOccurrences(of: ",", with: " ")
        let mne3 = mne2.replacingOccurrences(of: ".", with: " ")

        let clMne = mne3.condenseWhitespace()
        let mneAry = clMne.components(separatedBy: " ")
        return mneAry
    }
    
    func clickConfirm() {
        Slog("psg test:")
        var mnemonicStr = tfMnemonic.text ?? ""
//        //todelete
//        mnemonicStr = "dog owner follow fence swarm apology protect cheap snow neck prize enlist"
        let mneAry = getMneAryFromStr(mnemonicStr)
        
        if(mneAry == nil || mneAry?.count != 12 || encInfo.count == 0){
            self.showAlertCheckMnemonic()
        }else{
            let retAddr = WalletHelper.sharedInstance.restoreWallet(self, encInfo: encInfo, mnemonic: mnemonicStr)
            if let retAddr = retAddr {
                if retAddr.compare(preAddr, options: .caseInsensitive) == .orderedSame {
                    // 복구 성공
                    let retEnc = WalletHelper.sharedInstance.makeEncryptString(orgStr: retAddr)
                    self.delegate?.restoreWalletResult(self, action: .close, info: retEnc)
                }else{
                    self.showAlertCheckMnemonic()
                }
            }
            Slog("psg test : restore wallet")
        }
    }
}

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// MARK:// UITextFieldDelegate
extension RestoreWalletViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        Slog("textFieldShouldReturn called")
        if textField == tfMnemonic {
//            tfCheckPwd.text = tfGenPwd.text
//            self.clickConfirm()
        }
        textField.resignFirstResponder()
        return true
    }
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        Slog("textFieldDidEndEditing called")
        if textField == tfMnemonic {
//            tfCheckPwd.text = tfGenPwd.text
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    

}

class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 17,
        left: 17,
        bottom: 17,
        right: 17
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
