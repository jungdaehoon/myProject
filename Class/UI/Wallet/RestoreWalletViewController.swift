//
//  RestoreWalletViewController.swift
//  cereal
//
//  Created by develop wells on 2023/03/30.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation
import Combine

class RestoreWalletViewController: UIViewController {

    var viewModel : WalletViewModel = WalletViewModel()
    var mAlertView: UIAlertController?
    var encInfo     : String = ""
    var preAddr     : String = ""
    /// 이벤트를 넘깁니다.
    var completion  : (( _ value : Any? ) -> Void )? = nil

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

    /**
     데이터 세팅 입니다.
     - Date: 2023.03.13
     - Parameters:
        - captureMetadataOutPut : 캡쳐할 메타데이터 output 정보 입니다.
     - Throws: False
     - Returns:False
     */
    func setInitData( encInfo : String = "", preAddr : String = "", completion : (( _ value : Any? ) -> Void)? = nil ) {
        self.encInfo    = encInfo
        self.preAddr    = preAddr
        self.completion = completion
    }
    
    
    @IBAction func onConfirm(_ sender: Any) {
        self.clickConfirm()
    }
    
    @IBAction func onLostMnemonic(_ sender: Any) {
        showConfirmLostMnemonic()
    }
    @IBAction func onClose(_ sender: Any) {
        if let completion = self.completion { completion(nil) }
        self.popController(animated: true,animatedType: .down)
    }
    
    func showConfirmLostMnemonic(){
        /// 업데이트 안내 팝업 입니다.
        let alert = CMAlertView().setAlertView( titleText:"복구구문을 잃어버리셨나요?", detailObject: "복구 구문을 메모 하지 않은 경우나 분실한 경우는 관리자를 통한 요청으로 복구가 가능합니다.\n\n 복구 요청을 하시겠습니까?" as AnyObject )
        alert?.addAlertBtn(btnTitleText: "취소", completion: { result in
            
        })
        alert?.addAlertBtn(btnTitleText: "확인", completion: { result in
            if let completion = self.completion { completion("recovery-admin") }
            self.popController(animated: true,animatedType: .down)
        })
        alert?.show()
        

    }
    
    func showAlertCheckMnemonic(){
        CMAlertView().setAlertView(detailObject: "복구 구문 확인이 틀렸습니다. 복구 구문을 다시 한번 확인 해 주세요." as AnyObject, cancelText: "확인") { event in
        }
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
            /// 지갑 복구를 요청 합니다.
            self.viewModel.getRestoreWallet( encInfo: encInfo, mnemonic: mnemonicStr).sink { [self] value in
                /// 동일 여부를 체크 합니다.
                if let walletAddr = value,
                   walletAddr.compare(preAddr, options: .caseInsensitive) == .orderedSame {
                    /// AES 암호화 합니다
                    self.viewModel.getMakeEncryptString(orgStr: walletAddr).sink { value in
                        if let completion = self.completion { completion(NC.S(value)) }
                        self.popController(animated: true,animatedType: .down)
                    }.store(in: &self.viewModel.cancellableSet)
                }
                else
                {
                    self.showAlertCheckMnemonic()
                }
            }.store(in: &self.viewModel.cancellableSet)
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
