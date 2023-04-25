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

    func makeEncryptString(orgStr:String ) -> String {
        print("psg test:makeEncryptString")
        guard let encInfo = encryptWData(message:orgStr, key: encKey, iv: endIv) else { return "" }
        print("psg test:makeEncryptString : \(encInfo)")
        return encInfo
    }
    
    func decryptEncString(orgStr:String ) -> String {
//        print("psg test:makeEncryptString")
//        val decInfo = decryptWData(orgStr, encKey, endIv)
//        if (decInfo == nil) {
//            return ""
//        }
//
//        return decInfo
        ""
    }
    
    func getDecryptedWalletPasswdFromInfo(_ encInfo:String) -> String?{
        if let decInfo = decryptWData(encryptedData:encInfo,key: encKey, iv: endIv)
        {
            return decInfo + "0kbc"
        }
        return ""
    }

    func restoreWallet(_ vc: UIViewController,encInfo:String, mnemonic:String) -> String? {
        if let walletPass = getDecryptedWalletPasswdFromInfo(encInfo){
            return importWalletWithMnemonic(vc, walletPass: walletPass, mnemonics: mnemonic)
        }
        return ""
    }

    func importWalletWithMnemonic(_ vc: UIViewController,walletPass:String,mnemonics:String) -> String! {
        do {
            let twalletAddressKeyStore = try? BIP32Keystore(mnemonics: mnemonics, password: walletPass, mnemonicsPassword : walletPass, prefixPath: HDNode.defaultPath)
            
            let addrStr = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
//            self.walletAddressLabel.text = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"

            
            guard let wa = twalletAddressKeyStore?.addresses?.first else {
                vc.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                return ""
            }
            
            let privateKey = try twalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: wa)
            
            print("import: mnemonics  = \(mnemonics)")
            print("import: password  = \(walletPass)")
            print("import: address  = \(addrStr)")
            print("import: private key  = \(String(describing: privateKey?.toHexString()))")
            
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let keyData = try? JSONEncoder().encode(twalletAddressKeyStore?.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
            setWalletMnemonicToPref(mnemonics)
            return addrStr
            
        } catch {
            return ""
        }
    }

    
    func createWallet(_ vc: UIViewController,encInfo:String) -> String! {
        if let walletPass = getDecryptedWalletPasswdFromInfo(encInfo){
            return createMnemonics(vc, walletPass: walletPass)
        }
        return ""
    }
    
    func setWalletMnemonicToPref(_ mnemonic:String){
        SharedDefaults.default.walletMnemonic = mnemonic
        
    }
    func getWalletMnemonicFromPref() -> String? {
        return SharedDefaults.default.walletMnemonic
    }
    
    func checkWAddressWalletFile(_ vc: UIViewController,encInfo:String) -> String! {
        do {
//            let walletPass = getDecryptedWalletPasswdFromInfo(encInfo)
//            if(walletPass == nil){
//                return ""
//            }
            
            //get file from disk
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let path = userDir+"/keystore/"

            let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
            
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                if web3KeystoreManager?.addresses?.count == 0{
                    return ""
                }
                let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                
                guard let walletAddress = web3KeyStore?.addresses?.first else {
                    vc.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                    return ""
                }
                print("CheckExisting : walletAddress  = \(walletAddress.address)")
                return walletAddress.address
            }
        } catch {
            return ""
        }
        return ""
    }
    
    func checkPrivateKeyWithWalletFile(_ vc: UIViewController,encInfo:String) -> String! {
        do {
            if let walletPass = getDecryptedWalletPasswdFromInfo(encInfo){
                //get file from disk
                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

                 let path = userDir+"/keystore/"

                let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
                let tcount = web3KeystoreManager?.addresses?.count ?? 0
                if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                    let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                    
                    guard let walletAddress = web3KeyStore?.addresses?.first else {
                        vc.showAlertMessage(title: "", message: "Unable to load wallet", actionName: "Ok")
                        return ""
                    }
                    
                    let privateKey = try web3KeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
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
    
    func createMnemonics(_ vc: UIViewController,walletPass:String) -> String! {

        setWalletMnemonicToPref("")
        
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0 {
                //                let tempMnemonics = try? BIP39.(bitsOfEntropy: 256, language: .english)
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english)
                
                guard let tMnemonics = tempMnemonics else {
                    vc.showAlertMessage(title: "", message: "We are generateMnemonics unable to create wallet", actionName: "Ok")
                    return ""
                }
                setWalletMnemonicToPref(tMnemonics)

                let tempWalletAddressKeyStore = try? BIP32Keystore(mnemonics: tMnemonics, password: walletPass, mnemonicsPassword : walletPass,prefixPath: HDNode.defaultPath)
                guard let walletAddress = tempWalletAddressKeyStore?.addresses?.first else {
                    vc.showAlertMessage(title: "", message: "Unable to create wallet", actionName: "Ok")
                    return ""
                }

                let privateKey = try tempWalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                
                let keyData = try? JSONEncoder().encode(tempWalletAddressKeyStore?.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                
                print("create: mnemonics  = \(tMnemonics)")
                print("create: password  = \(walletPass)")
                print("create: address key  = \(walletAddress.address)")
                print("create: private key  = \(String(describing: privateKey?.toHexString()))")
                let pForcedStr2 : String! = String(describing: privateKey?.toHexString())
                let pForcedStr : String! =  privateKey?.toHexString()
                return walletAddress.address + ":" + pForcedStr
            }
        } catch {
            return ""
        }
        return ""
    }
    
    func checkIfSameMnemonic( typedMnemonic : String?) -> Bool{
        guard let Mnemonic      = typedMnemonic else { return false }
        var refindedMnemonic    = Mnemonic.trimmingCharacters(in: .whitespaces)
        if let savedMnemonic    = getWalletMnemonicFromPref() {
            if savedMnemonic.compare(refindedMnemonic, options: .caseInsensitive) == .orderedSame
            {
                return true
            }
        }
        return false
    }

}



