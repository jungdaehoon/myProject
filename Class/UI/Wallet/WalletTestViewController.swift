//
//  WalletTestViewController.swift
//  cereal
//
//  Created by develop wells on 2023/03/20.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import Web3Core


class WalletTestViewController: UIViewController {
    
    let tempPwd = "0123450kbc"
    
    var _walletAddress: String {
        set {
//            self.continueButton.isHidden = false
//            self.walletAddressLabel.text = newValue
        }
        get {
            return self._walletAddress
        }
    }
    var _mnemonics: String = ""
    var parentvc : UIViewController?  = nil

    @IBOutlet weak var tfGenPwd: UITextField!
    
    @IBOutlet weak var tfCreWallet: UITextField!
    @IBOutlet weak var tfCrePriKey: UITextField!
    @IBOutlet weak var tfCreMne: UITextField!
    
    @IBOutlet weak var tfResWallet: UITextField!
    
    @IBOutlet weak var tfCheckPwd: UITextField!
    @IBOutlet weak var tfCheckPriKey: UITextField!
    
    
    @IBAction func onIfTest1(_ sender: Any) {
        onIfTestGetWaddr(sender)
        
    }
    
    @IBAction func onIfTest2(_ sender: Any) {
        onIfTestShowMnemonic(sender)
    }
    
    func onIfTestGetWaddr(_ sender: Any) {
        let paramAry = [ "encinfo", nil]
        let arrGetWAddr  = ["callback", SCRIPT_MESSAGES.getWAddress, paramAry ] as [Any]
        self.walletCallTest(arrGetWAddr)
    }
    
    typealias ShowWalletClousre = (String, Error?) -> Void // hybridShowLoginCompletion 멤버 타입  (success,error) 으로 콜백
    var hybridShowWalletCompletion :  ShowWalletClousre? // wallet 관련 콜백 호출 : 로그인과 동일 형식 사용
    
    func onIfTestShowMnemonic(_ sender: Any) {
//        let paramAry = [ "true", nil]
//        let arr = ["callback", WalletInterface.COMMAND_WALLET_SHOW_MNEMONIC, paramAry ] as [Any]
//        self.walletCallTest(arr)
        
//        self.hybridShowWalletCompletion = completion
        let mainStoryboard  = UIStoryboard(name: "Wallet", bundle: nil)
        let vc              = mainStoryboard.instantiateViewController(withIdentifier: "ShowMnemonicViewController") as? ShowMnemonicViewController
        vc!.showNext         =  true
        self.navigationController!.pushViewController(vc!, animated: true, animatedType :.up)
    }
    

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func onRestoreWallet(_ sender: Any){
        print("onRestoreWallet")
        let tPwdEnc = WalletHelper.sharedInstance.makeEncryptString(orgStr:tfGenPwd.text ?? "")
        //let tPwdDec = WalletHelper.sharedInstance.getDecryptedWalletPasswdFromInfo(encInfo:tPwdEnc.text ?? "")
        let tMnemonic = WalletHelper.sharedInstance.getWalletMnemonicFromPref() ?? ""
        guard let ret = WalletHelper.sharedInstance.restoreWallet(self,encInfo:tPwdEnc,mnemonic:tMnemonic) else { return }
        tfResWallet.text =  ret
        print("onRestoreWallet:ret=",tfResWallet.text!)
    }
    
    @IBAction func onGetWAddress(_ sender: Any) {
        print("onGetWAddress")
        let tPwdEnc = WalletHelper.sharedInstance.makeEncryptString(orgStr:tfGenPwd.text ?? "")
        let ret = WalletHelper.sharedInstance.checkWAddressWalletFile(self,encInfo:tPwdEnc)
        let retMne = WalletHelper.sharedInstance.checkIfSameMnemonic(typedMnemonic: "this is a")
        tfCheckPwd.text =  ret

        print("onGetWAddress:ret=",ret)
    }
    @IBAction func onReadQR(_ sender: Any) {
        print("onReadQR")
        let mainStoryboard  = UIStoryboard(name: "Wallet", bundle: nil)
        let vc              = mainStoryboard.instantiateViewController(withIdentifier: "QRReaderViewController") as? QRReaderViewController
        //vc!.delegate         = self
        self.navigationController!.pushViewController(vc!, animated: true, animatedType :.up)
    }
    
    @IBAction func onGetPriKey(_ sender: Any) {
        print("onGetPriKey")
        let tPwdEnc = WalletHelper.sharedInstance.makeEncryptString(orgStr:tfGenPwd.text ?? "")
        let ret = WalletHelper.sharedInstance.checkPrivateKeyWithWalletFile(self,encInfo:tPwdEnc)
        
        tfCheckPriKey.text =  ret

        print("onGetPriKey:ret=",ret)
    }
    
    
    @IBAction func onCreateWallet(_ sender: Any) {
        print("onCreateWallet")
        let tPwdEnc = WalletHelper.sharedInstance.makeEncryptString(orgStr:tfGenPwd.text ?? "")
        //let tPwdDec = WalletHelper.sharedInstance.getDecryptedWalletPasswdFromInfo(encInfo:tPwdEnc.text ?? "")
        let ret = WalletHelper.sharedInstance.createWallet(self,encInfo:tPwdEnc)
        print("onCreateWallet:ret=",ret)
        tfCreMne.text = WalletHelper.sharedInstance.getWalletMnemonicFromPref()
        
        let retData = ret?.components(separatedBy: ":")

        if(retData == nil || retData!.count < 2){
            return
        }
        
        tfCreWallet.text =  retData?[0]
        tfCrePriKey.text = retData?[1]
    }
    
    
    @IBAction func onGeneratePasswd(_ sender: Any) {
        print("onGeneratePasswd")
        tfGenPwd.becomeFirstResponder()
    }
    @IBAction func onWalletTest(_ sender: Any) {
        print("onTestWallet")
//        createMnemonics()
        checkExistingWalletFile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       tfGenPwd.delegate = self
        
       tfCreWallet.delegate = self
       tfCrePriKey.delegate = self
       tfCreMne.delegate = self
        
       tfResWallet.delegate = self
        
       tfCheckPwd.delegate = self
       tfCheckPriKey.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func importWalletWith(privateKey: String) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
            return
        }
        do {
            let keystore =  try EthereumKeystoreV3(privateKey: dataKey, password: tempPwd)
            if let myWeb3KeyStore = keystore {
                let manager = KeystoreManager([myWeb3KeyStore])
                let address = keystore?.addresses?.first
#if DEBUG
                print("Address :::>>>>> ", address)
                print("Address :::>>>>> ", manager.addresses)
#endif
                let walletAddress = manager.addresses?.first?.address
//                self.walletAddressLabel.text = walletAddress ?? "0x"

                print(walletAddress)
            } else {
                print("error")
            }
        } catch {
#if DEBUG
            print("error creating keyStore")
            print("Private key error.")
#endif
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }

    }

    func importWalletWith(mnemonics: String) {
        do {
            //        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics, password: tempPwd, mnemonicsPassword : tempPwd, prefixPath: "m/44'/77777'/0'/0")
            let twalletAddressKeyStore = try? BIP32Keystore(mnemonics: mnemonics, password: tempPwd, mnemonicsPassword : tempPwd, prefixPath: HDNode.defaultPath)
            
            let addrStr = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
//            self.walletAddressLabel.text = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
            print("import: mnemonics  = \(mnemonics)")
            print("import: password  = \(tempPwd)")
            print("import: address  = \(addrStr)")
            
            guard let wa = twalletAddressKeyStore?.addresses?.first else {
                self.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                return
            }
            
            let privateKey = try twalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: tempPwd, account: wa)
            
            print("import: private key  = \(String(describing: privateKey?.toHexString()))")
            
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let keyData = try? JSONEncoder().encode(twalletAddressKeyStore?.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
            
            print("import: end")
            
        } catch {
            
        }
    }
    
    func checkPrivateKeyWithExistingWalletFile() {
        do {
            //get file from disk
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

             let path = userDir+"/keystore/"

            let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
            let tcount = web3KeystoreManager?.addresses?.count ?? 0
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                
                guard let walletAddress = web3KeyStore?.addresses?.first else {
                    self.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                    return
                }
                
                let privateKey = try web3KeyStore?.UNSAFE_getPrivateKeyData(password: tempPwd, account: walletAddress)
                print("checkPrivate : walletAddress  = \(walletAddress)")
                print("checkPrivate: private key  = \(String(describing: privateKey?.toHexString()))")
                
            }
            
        } catch {
            
        }
    }
    
    func checkExistingWalletFile() {
        do {
            //get file from disk
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

             let path = userDir+"/keystore/"

            let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
            
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                
                guard let walletAddress = web3KeyStore?.addresses?.first else {
                    self.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                    return
                }
                print("CheckExisting : walletAddress  = \(walletAddress)")
            }
            
        } catch {
            
        }
    }
    
    func createMnemonics() {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                //                let tempMnemonics = try? BIP39.(bitsOfEntropy: 256, language: .english)
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english)
                
                guard let tMnemonics = tempMnemonics else {
                    self.showAlertMessage(title: "", message: "We aregenerateMnemonics unable to create wallet", actionName: "Ok")
                    return
                }
                self._mnemonics = tMnemonics
                print(_mnemonics)

                let tempWalletAddressKeyStore = try? BIP32Keystore(mnemonics: self._mnemonics, password: tempPwd, mnemonicsPassword : tempPwd,prefixPath: HDNode.defaultPath)
                guard let walletAddress = tempWalletAddressKeyStore?.addresses?.first else {
                    self.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                    return
                }
                self._walletAddress = walletAddress.address
                let privateKey = try tempWalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: tempPwd, account: walletAddress)
                
                let keyData = try? JSONEncoder().encode(tempWalletAddressKeyStore?.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                
                print("create: mnemonics  = \(self._mnemonics)")
                print("create: password  = \(tempPwd)")
                print("create: address key  = \(walletAddress.address)")
                print("create: private key  = \(String(describing: privateKey?.toHexString()))")
                
//                var tW =  Web3Wallet(address: walletAddress.address, data: keyData, name: "testname", type: .hd(mnemonics: tMnemonics))
            }
        } catch {

        }

    }
}


// MARK:// UITextFieldDelegate
extension WalletTestViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        print("textFieldShouldReturn called")
        if textField == tfGenPwd {
//            tfCheckPwd.text = tfGenPwd.text
        } else if textField == tfCreWallet{
        }
        textField.resignFirstResponder()
        return true
    }
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        print("textFieldShouldBeginEditing called")
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing called")
        if textField == tfGenPwd {
            tfCheckPwd.text = tfGenPwd.text
        } else if textField == tfCreWallet{
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    
}

extension WalletTestViewController {
    // 유티리리티  관련 UtilityInterface
//    func utilityCallTest(_ message:  Array<Any>  ) {
//
//        let action = message[1] as! String
//
//        let hybridInterface = UtilityInterface(viewController: self, command: message) { (hybridResult) in
//            var callbackArray = message[0] as! Array<String>
//            if callbackArray.count > 0 {
//                print("psg test : hybridInterface result = \(hybridResult)")
//                switch(hybridResult) {
//                case .success(let retMessage) :
//                    if action == UtilityInterface.COMMAND_GET_APP_VERSION {
//
//                        //self.callback(callbackId: callbackArray[0], retMessage: retMessage , isJson: true )
//                    }
//                    else {
//                        //self.callback(callbackId: callbackArray[0], retMessage: retMessage  )
//                    }
//                default:
//                    ()
//                }
//            }
//        }
//    }
    
    // 유티리리티  관련 UtilityInterface
    func walletCallTest(_ message:  Array<Any>  ) {
        let action = message[1] as! String
        /*
        let hybridInterface = WalletInterface(viewController: self, command: message) { (hybridResult) in
            var callbackArray = message[0] as! Array<String>
            if callbackArray.count > 0 {
                switch(hybridResult) {
                case .success(let retMessage) :
                    if action == WalletInterface.COMMAND_WALLET_GETWADDRESS ||
                        action == WalletInterface.COMMAND_WALLET_CHECK_WINFO ||
                        action == WalletInterface.COMMAND_WALLET_CREATE_WINFO ||
                        action == WalletInterface.COMMAND_WALLET_RESTORE_WINFO ||
                        action == WalletInterface.COMMAND_WALLET_SHOW_MNEMONIC ||
                        action == WalletInterface.COMMAND_WALLET_READ_QRINFO ||
                        action == WalletInterface.COMMAND_WALLET_QUERY_KAKAO
                    {
//                        self.callback(callbackId: callbackArray[0], retMessage: retMessage , isJson: true )
                    }
                    else {
//                        self.callback(callbackId: callbackArray[0], retMessage: retMessage  )
                    }
                default:
                    ()
                }
            }
        }
         */
    }
    
}


extension UIViewController {
    func showAlertMessage(title: String = "MyWeb3Wallet", message: String = "Message is empty", actionName: String = "확인") {
        let alert = UIAlertController(title: title,
                                      message:  message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: actionName,
                                      style: .default,
                                      handler: { action in
        }))
        
        self.present(alert,  animated: true, completion: nil)
    }
}
