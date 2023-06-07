//
//  WalletViewModel.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/15.
//

import Foundation
import Combine
import CryptoSwift
import web3swift
import Web3Core

/**
 월렛 모델 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.05.15
*/
class WalletViewModel : BaseViewModel {
    static let sharedInstance = WalletViewModel()
    /// AES 키 정보 입니다.
    static let W_ENCKEY : String = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "W_ENCKEY") as? String ?? ""
    /// CBC IV 정보 입니다.
    static let W_ENCIV : String  = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "W_ENCIV") as? String ?? ""
    
    
    /**
     정보를 받아 AES 암호화 합니다.
     - Date: 2023.06.02
     - Parameters:
        - message : 변경 할 문자 정보를 받습니다.
        - key : AES 암호화 키 정보 입니다.
        - iv : CBC IV 정보를 받습니다.
     - Throws: False
     - Returns:
        암호화된 ENC 정보를 리턴 합니다. (String?)
     */
    private func getEncryptWData( message: String, key: String, iv: String ) -> String?
    {
        do{
            let data = message.data(using: .utf8)!
            // let enc = try AES(key: key, iv: iv, padding: .pkcs5).encrypt([UInt8](data))
            let enc = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iv.utf8)), padding: .pkcs5).encrypt([UInt8](data))
            let encryptedData = Data(enc)
            print("encryptWData enc : \(enc) message : \(message) key : \(key) iv : \(iv) base64 : \(encryptedData.base64EncodedString())")
            return encryptedData.base64EncodedString()
        }catch{
            return ""
        }
    }
    
    
    /**
     ENC 데이터를 복호화 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encryptedData : 복호화할 데이터 입니다.
        - key : AES 암호화 키 정보 입니다.
        - iv : CBC IV 정보를 받습니다.
     - Throws: False
     - Returns:
        복호화 정보를 리턴 합니다. (String?)
     */
    private func getDecryptWData( encryptedData: String, key: String, iv: String ) -> String?
    {
        do{
            let data = NSData(base64Encoded: encryptedData, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let dec = try AES(key: key, iv: iv, padding: .pkcs5).decrypt([UInt8](data))
            let decryptedData = Data(dec)
            return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
        }catch{
            return ""
        }
    }
    
    
    /**
     지갑 비밀번호 ENC 데이터를 복호화 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encInfo : 복호화할 데이터 입니다.
     - Throws: False
     - Returns:
        복호화 정보를 리턴 합니다. (String?)
     */
    private func getDecryptedWalletPasswdFromInfo(_ encInfo:String) -> String?
    {
        /// ENC 복호화요청하여 정보를 가져 옵니다.
        if let decInfo = getDecryptWData(encryptedData:encInfo,key: WalletViewModel.W_ENCKEY, iv: WalletViewModel.W_ENCIV) {
            return decInfo + "0kbc"
        }
        return ""
    }
    
    
    /**
     지갑을 복구할 pass 정보를 찾아 리턴 합니다.
     - Date: 2023.06.02
     - Parameters:
        - walletPass : enc 정보를 받습니다.
        - mnemonic : 닉모닉 정보 입니다.
     - Throws: False
     - Returns:
        복구된 지갑 Pass 정보를 리턴 합니다. (String?)
     */
    private func setWalletWithMnemonuc( walletPass : String = "", mnemonics : String = "" ) -> String?
    {
        do {
            let twalletAddressKeyStore = try? BIP32Keystore(mnemonics: mnemonics, password: walletPass, mnemonicsPassword : walletPass, prefixPath: HDNode.defaultPath)
            
            let addrStr = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
            /// 블럭체인에서 대문자가 있으면 오류발생으로 전부 소문자로 변경 합니다.
            let lowerWalletAddress = addrStr.lowercased()
            
            guard let wa = twalletAddressKeyStore?.addresses?.first else {
                CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                }
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
            SharedDefaults.default.walletMnemonic = mnemonics
            SharedDefaults.default.walletAddress  = lowerWalletAddress
            return lowerWalletAddress
            
        } catch {
            return ""
        }
    }
    
    
    /**
     신규로 생성된 wallet 닉모닉을 생성 합니다.
     - Date: 2023.06.02
     - Parameters:
        - walletPass : 닉모닉 생성시 사용할 wallet 페스워드 입니다.
     - Throws: False
     - Returns:
        신규로 생성된 wallet 주소를 리턴 합니다. (String?)
     */
    private func setCreateMnemonics( walletPass : String = "" ) -> String? {
        SharedDefaults.default.walletMnemonic = ""
        SharedDefaults.default.walletAddress  = ""
        let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore", scanForHDwallets: true, suffix: "json")
        let tcount              = web3KeystoreManager?.addresses?.count ?? 0
        do {
            if tcount >= 1 { self.removeAllKeystorefiles(path: userDir + "/keystore") }
            if web3KeystoreManager?.addresses?.count ?? 0 >= 0
            {
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english)
                guard let tMnemonics = tempMnemonics else {
                    CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                    }
                    return ""
                }
                
                let tempWalletAddressKeyStore = try? BIP32Keystore(mnemonics: tMnemonics, password: walletPass, mnemonicsPassword : walletPass,prefixPath: HDNode.defaultPath)
                guard let walletAddress = tempWalletAddressKeyStore?.addresses?.first else {
                    CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                    }
                    return ""
                }
                
                let lowerWalletAddress = walletAddress.address.lowercased()
                SharedDefaults.default.walletMnemonic = tMnemonics
                SharedDefaults.default.walletAddress  = lowerWalletAddress
                
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
    
    
    /**
     로컬 저장된 wallet 파일을 삭제 합니다.
     - Date: 2023.06.02
     - Parameters:
        - path : 파일 위치 정보 입니다.
     - Throws: False
     - Returns:False
     */
    private func removeAllKeystorefiles( path : String = "" )
    {
        let fileManager     = FileManager.default
        var isDir: ObjCBool = false
        let exists          = fileManager.fileExists(atPath: path, isDirectory: &isDir)
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
            Slog("Unable to delete old archived log file \(error.localizedDescription)", category: .wallet)
        }
    }
    
    
    /**
     Encrypt 정보로 변경하여 리턴 합니다.
     - description: NFT 에 사용할 정보를 받아 Enc 정보로 AES 암호화 하여 리턴 합니다. 사용되는 키정보는 "W_ENCKEY", "W_ENCIV" 정보를 사용 합니다.
     - Date: 2023.06.02
     - Parameters:
        - orgStr : enc 변경할 정보를 받습니다.
     - Throws: False
     - Returns:
        암호화된 ENC 정보를 리턴 합니다. Future<String?, Never>
     */
    func getMakeEncryptString( orgStr : String ) -> Future<String?, Never>
    {
        return Future<String?, Never> { promise in
            if let encInfo = self.getEncryptWData( message: orgStr, key: WalletViewModel.W_ENCKEY, iv: WalletViewModel.W_ENCIV) {
                promise(.success(encInfo))
            }
            else
            {
                promise(.success(""))
            }
        }
    }
    

    /**
     지갑 복구를 요청 합니다.
     - description: 웹에서 복구 요청으로 받은 encinfo 정보와 유저가 입력한 닉모닉 정보를 받아 복구구분을 진행 복구된 지갑 정보를 리턴 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
        - mnemonic : 복구할 닉모닉 정보 입니다.
     - Throws: False
     - Returns:
        암호화된 ENC 정보를 리턴 합니다. Future<String?, Never>
     */
    func getRestoreWallet( encInfo : String = "", mnemonic : String = "" ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            /// 복호화된 password 를 가져 옵니다.
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                /// 복구된 지갑 정보를 가져 옵니다.
                if let wallet = self.setWalletWithMnemonuc(walletPass: walletPass, mnemonics: mnemonic) {
                    promise(.success(wallet))
                } else { promise(.success("")) }
            } else { promise(.success("")) }
        }
    }
    
    
    /**
     로컬에 저장된 wallet 정보를 리턴 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
     - Throws: False
     - Returns:
        로컬 wallet 주소를 리턴 합니다. Future<String?, Never>
     */
    func getWalletAdderss( encInfo : String = "" ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let path                = userDir + "/keystore/"
            let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
            
            if web3KeystoreManager?.addresses?.count ?? 0 >= 1
            {
                let web3KeyStore = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                
                guard let walletAddress = web3KeyStore?.addresses?.first else {
                    CMAlertView().setAlertView(detailObject: "저장된 정보를 찾을 수 없습니다." as AnyObject, cancelText: "확인") { event in
                    }
                    return
                }
                Slog("CheckExisting : walletAddress  = \(walletAddress.address)",category: .wallet)
                promise(.success(walletAddress.address))
            }
        }
    }
    
    
    /**
     로컬에 저장된 wallet 개인 키정보를 리턴 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
     - Throws: False
     - Returns:
        로컬 개인 키정보를 리턴 합니다. Future<String?, Never>
     */
    func getWalletPrivateKey( encInfo : String = "" )  -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            do {
                if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                    let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let path                = userDir+"/keystore/"
                    let web3KeystoreManager = KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
                    let tcount              = web3KeystoreManager?.addresses?.count ?? 0
                    if tcount >= 1
                    {
                        let web3KeyStore        = web3KeystoreManager?.walletForAddress((web3KeystoreManager?.addresses?[0])!) as? BIP32Keystore
                        guard let walletAddress = web3KeyStore?.addresses?.first else {
                            CMAlertView().setAlertView(detailObject: "저장된 정보를 찾을 수 없습니다." as AnyObject, cancelText: "확인") { event in
                            }
                            return
                        }
                        let privateKey          = try web3KeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                        Slog("checkPrivate : walletAddress  = \(walletAddress)", category: .wallet)
                        Slog("checkPrivate: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                        
                        promise(.success(privateKey?.toHexString()))
                    }
                }
            } catch {
                Slog(error, category: .wallet)
                promise(.success(""))
            }
        }
    }
    
    
    /**
     신규 생성된 지갑 정보를 로컬에 저장 합니다.
     - description: 웹에서 신규 wallet 생성후 정보를 받아 로컬에 파일로 저장 합니다. (/keystore.json)
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
     - Throws: False
     - Returns:
        저장후 wallet 주소를 리턴 합니다. Future<String?, Never>
     */
    func setCreateWallet( encInfo:String ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            /// 복호화된 password 를 가져 옵니다.
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                /// 신규로 저장된 wallet 주소를 받습니다.
                if let walletAddr = self.setCreateMnemonics( walletPass: walletPass ) {
                    promise(.success(walletAddr))
                } else { promise(.success("")) }
            } else { promise(.success("")) }
            
        }
    }
}
