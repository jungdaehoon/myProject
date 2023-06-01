//
//  WalletHelper.swift
//  cereal
//
//  Created by develop wells on 2023/03/22.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation
import CryptoSwift
import web3swift
import Web3Core


class WalletHelper
{
    static let sharedInstance = WalletHelper()
    static let W_ENCKEY : String = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "W_ENCKEY") as? String ?? ""
    static let W_ENCIV : String = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "W_ENCIV") as? String ?? ""
    
    private init() {}
    
    let encKey = "CpUzZ08BAcn46Ie1"
    let endIv = "tPAG8Ru1SS5qjyEo"
    
    var tempWInfo = ""
    
//    func aesEncrypt(key: String, iv: String, message: String) throws -> String{
//        let data = message.data(using: .utf8)!
//        // let enc = try AES(key: key, iv: iv, padding: .pkcs5).encrypt([UInt8](data))
//        let enc = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iv.utf8)), padding: .pkcs5).encrypt([UInt8](data))
//        let encryptedData = Data(enc)
//        return encryptedData.base64EncodedString()
//    }
//
//    func aesDecrypt(key: String, iv: String, message: String) throws -> String {
//        let data = NSData(base64Encoded: message, options: NSData.Base64DecodingOptions(rawValue: 0))!
//        let dec = try AES(key: key, iv: iv, padding: .pkcs5).decrypt([UInt8](data))
//        let decryptedData = Data(dec)
//        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
//    }
//
    // Function to encrypt data using AES
    func encryptWData(message: String, key: String, iv: String) -> String? {
        do{
            let data = message.data(using: .utf8)!
            // let enc = try AES(key: key, iv: iv, padding: .pkcs5).encrypt([UInt8](data))
            let enc = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iv.utf8)), padding: .pkcs5).encrypt([UInt8](data))
            let encryptedData = Data(enc)
            return encryptedData.base64EncodedString()
        }catch{
            return ""
        }
    }
    

    // Function to decrypt data using AES
    func decryptWData(encryptedData: String, key: String, iv: String) -> String? {
        do{
            let data = NSData(base64Encoded: encryptedData, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let dec = try AES(key: key, iv: iv, padding: .pkcs5).decrypt([UInt8](data))
            let decryptedData = Data(dec)
            return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
        }catch{
            return ""
        }
    }
    
    func makeEncryptString(orgStr:String ) -> String? {
        print("psg test:makeEncryptString")
        if let encInfo = encryptWData(message:orgStr, key: WalletHelper.W_ENCKEY, iv: WalletHelper.W_ENCIV) {
            return encInfo
        }
        return ""
    }
    
    
    func decryptEncString(orgStr:String ) -> String {
//        Slog("psg test:makeEncryptString")
//        val decInfo = decryptWData(orgStr, encKey, endIv)
//        if (decInfo == nil) {
//            return ""
//        }
//
//        return decInfo
        ""
    }
    
    func getDecryptedWalletPasswdFromInfo(_ encInfo:String) -> String?{
        if let decInfo = decryptWData(encryptedData:encInfo,key: WalletHelper.W_ENCKEY, iv: WalletHelper.W_ENCIV) {
            return decInfo + "0kbc"
        }
        return ""
    }

    func restoreWallet(_ vc: UIViewController,encInfo:String, mnemonic:String) -> String? {
        if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
            // 이더리움 지갑 생성
            return self.importWalletWithMnemonic(vc, walletPass: walletPass, mnemonics: mnemonic)
        }
        return ""
    }
    
    func importWalletWithMnemonic(_ vc: UIViewController,walletPass:String,mnemonics:String) -> String? {
        do {
            let twalletAddressKeyStore = try? BIP32Keystore(mnemonics: mnemonics, password: walletPass, mnemonicsPassword : walletPass, prefixPath: HDNode.defaultPath)
            
            let addrStr = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
//            self.walletAddressLabel.text = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
            /// 블럭 체인에서 대문자가 있으면 오류발생으로 전부 소문자로 변경 합니다.
            let lowerWalletAddress = addrStr.lowercased()
            
            guard let wa = twalletAddressKeyStore?.addresses?.first else {
                vc.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                return ""
            }
            
            let privateKey = try twalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: wa)
            
            Slog("import: mnemonics  = \(mnemonics)", category: .wallet)
            Slog("import: password  = \(walletPass)", category: .wallet)
            Slog("import: lowerWalletAddress  = \(lowerWalletAddress)", category: .wallet)
            Slog("import: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
            
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let keyData = try? JSONEncoder().encode(twalletAddressKeyStore?.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
            self.setWalletMnemonicToPref(mnemonics)
            self.setWalletAddressToPref(lowerWalletAddress)
            return lowerWalletAddress
            
        } catch {
            return ""
        }
    }
    

    
    func createWallet(_ vc: UIViewController,encInfo:String) -> String? {
        if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo){
            return self.createMnemonics(vc, walletPass: walletPass)
        }
        return ""
    }
    
    func setWalletMnemonicToPref(_ mnemonic:String){
        SharedDefaults.default.walletMnemonic = mnemonic
        
    }
    func getWalletMnemonicFromPref() -> String? {
        return SharedDefaults.default.walletMnemonic
    }
    
    func setWalletAddressToPref(_ addr:String){
        SharedDefaults.default.walletAddress = addr
        
    }
    
    func getWalletAddressFromPref() -> String! {
        return SharedDefaults.default.walletAddress
    }

    
    func checkWAddressWalletFile(_ vc: UIViewController,encInfo:String) -> String? {
        let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path                = userDir+"/keystore/"
        let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
        
        if web3KeystoreManager?.addresses?.count ?? 0 >= 1
        {
            let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
            guard let walletAddress = web3KeyStore?.addresses?.first else {
                vc.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                return ""
            }
            print("CheckExisting : walletAddress  = \(walletAddress.address)")
            return walletAddress.address
        }
        return ""
    }
    
    
    func checkPrivateKeyWithWalletFile(_ vc: UIViewController,encInfo:String) -> String? {
        do {
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let path                = userDir+"/keystore/"
                let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
                let tcount              = web3KeystoreManager?.addresses?.count ?? 0
                
                if web3KeystoreManager?.addresses?.count ?? 0 >= 1
                {
                    let web3KeyStore        = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                    guard let walletAddress = web3KeyStore?.addresses?.first else {
                        vc.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                        return ""
                    }
                    let privateKey          = try web3KeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                    print("checkPrivate : walletAddress  = \(walletAddress)")
                    print("checkPrivate: private key  = \(String(describing: privateKey?.toHexString()))")
                    return privateKey?.toHexString()
                }
            }
        } catch {
            print(error)
            return ""
        }
        return ""
    }
    
    
    func removeAllKeystorefiles(path:String){
        let fileManager     = FileManager.default
        var isDir: ObjCBool = false
        var exists          = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if !isDir.boolValue || !exists { return }
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: path)
            for file in allFiles
            {
                var filePath = path
                if !path.hasSuffix("/") {
                    filePath = path + "/"
                }
                filePath = filePath + file
                try fileManager.removeItem(atPath: filePath)
            }
        }
        catch let error as NSError {
            print("Unable to delete old archived log file \(error.localizedDescription)")
        }
    }
    
    
    func createMnemonics(_ vc: UIViewController,walletPass:String) -> String! {

        self.setWalletMnemonicToPref("")
        self.setWalletAddressToPref("")
        let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore", scanForHDwallets: true, suffix: "json")
        let tcount              = web3KeystoreManager?.addresses?.count ?? 0
        do {
            if tcount >= 1 {
                //remove prev files
                self.removeAllKeystorefiles(path: userDir + "/keystore")
            }
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                //                let tempMnemonics = try? BIP39.(bitsOfEntropy: 256, language: .english)
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english)
                
                guard let tMnemonics = tempMnemonics else {
                    vc.showAlertMessage(title: "", message: "We are generateMnemonics unable to create wallet", actionName: "Ok")
                    return ""
                }
                
                let tempWalletAddressKeyStore = try? BIP32Keystore(mnemonics: tMnemonics, password: walletPass, mnemonicsPassword : walletPass,prefixPath: HDNode.defaultPath)
                guard let walletAddress = tempWalletAddressKeyStore?.addresses?.first else {
                    vc.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                    return ""
                }
                
                let lowerWalletAddress = walletAddress.address.lowercased()
                
                self.setWalletMnemonicToPref(tMnemonics)
                self.setWalletAddressToPref(lowerWalletAddress)
                
                let privateKey  = try tempWalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                let keyData     = try? JSONEncoder().encode(tempWalletAddressKeyStore?.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                
                Slog("create: mnemonics  = \(tMnemonics)", category: .wallet)
                Slog("create: password  = \(walletPass)", category: .wallet)
                Slog("create: address key  = \(lowerWalletAddress)", category: .wallet)
                Slog("create: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                let pForcedStr : String!    =  privateKey?.toHexString()
                return lowerWalletAddress + ":" + pForcedStr
            }
        } catch {
            return ""
        }
        return ""
    }
    
    func checkIfSameMnemonic( typedMnemonic:String? ) -> Bool{
        if var refindedMnemonic = typedMnemonic,
           let savedMnemonic    = self.getWalletMnemonicFromPref(){
            refindedMnemonic = refindedMnemonic.trimmingCharacters(in: .whitespaces)
            if savedMnemonic.compare(refindedMnemonic, options: .caseInsensitive) == .orderedSame
            {
                return true
            }
        }
        return false
    }

}



