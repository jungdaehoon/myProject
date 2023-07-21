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
    static let W_ENCKEY : String = Bundle.main.infoDictionary?["W_ENCKEY"] as? String ?? ""
    /// CBC IV 정보 입니다.
    static let W_ENCIV  : String = Bundle.main.infoDictionary?["W_ENCIV"] as? String ?? ""    
    /// 기본 폴더 정보 입니다.
    static let defaultFolder : String = "/keystore"
    
    
    
    /**
     정보를 받아 AES 암호화 합니다. ( J.D.H VER : 1.0.0 )
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
            let enc = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iv.utf8)), padding: .pkcs5).encrypt([UInt8](data))
            let encryptedData = Data(enc)
            print("encryptWData enc : \(enc) message : \(message) key : \(key) iv : \(iv) base64 : \(encryptedData.base64EncodedString())")
            return encryptedData.base64EncodedString()
        }catch{
            return ""
        }
    }
    
    
    /**
     ENC 데이터를 복호화 합니다. ( J.D.H VER : 1.0.0 )
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
     지갑 비밀번호 ENC 데이터를 복호화 합니다. ( J.D.H VER : 1.0.0 )
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
     지갑을 복구할 pass 정보를 찾아 리턴 합니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.06.02
     - Parameters:
        - walletPass : enc 정보를 받습니다.
        - mnemonic : 닉모닉 정보 입니다.
     - Throws: False
     - Returns:
        복구된 지갑 Pass 정보를 리턴 합니다. (String?)
     */
    private func setWalletWithMnemonuc( walletPass : String = "", mnemonics : String = "" ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            do {
                let twalletAddressKeyStore = try? BIP32Keystore(mnemonics: mnemonics, password: walletPass, mnemonicsPassword : walletPass, prefixPath: HDNode.defaultPath)
                let addrStr = "\(twalletAddressKeyStore?.addresses?.first?.address ?? "0x")"
                /// 블럭체인에서 대문자가 있으면 오류발생으로 전부 소문자로 변경 합니다.
                let lowerWalletAddress = addrStr.lowercased()
                
                guard let wa = twalletAddressKeyStore?.addresses?.first else {
                    CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                        promise(.success(""))
                    }
                    return
                }
                
                let privateKey = try twalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: wa)
                
                Slog("import: mnemonics  = \(mnemonics)", category: .wallet)
                Slog("import: password  = \(walletPass)", category: .wallet)
                Slog("import: twalletAddressKeyStore?.addresses  = \(twalletAddressKeyStore?.addresses)", category: .wallet)
                Slog("import: lowerWalletAddress  = \(lowerWalletAddress)", category: .wallet)
                Slog("import: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                
                let keyData = try? JSONEncoder().encode(twalletAddressKeyStore?.keystoreParams)
                /// 월렛 관련 키스토어 폴더 여부를 체크 합니다.
                self.isFolder().sink { success in
                    if success
                    {
                        /// 월렛 관련 키 파일을 추가 합니다.
                        self.addFile(keyData).sink { success in
                            if success
                            {
                                SharedDefaults.default.walletMnemonic = mnemonics
                                SharedDefaults.default.walletAddress  = lowerWalletAddress
                                promise(.success(lowerWalletAddress))
                            }
                            else
                            {
                                promise(.success(""))
                            }
                        }.store(in: &self.cancellableSet)
                    }
                    else
                    {
                        /// 월렛 관련 키스토어 폴더 를 생성 합니다.
                        self.addFolder().sink { success in
                            if success
                            {
                                /// 월렛 관련 키 파일을 추가 합니다.
                                self.addFile(keyData).sink { success in
                                    if success
                                    {
                                        SharedDefaults.default.walletMnemonic = mnemonics
                                        SharedDefaults.default.walletAddress  = lowerWalletAddress
                                        promise(.success(lowerWalletAddress))
                                    }
                                    else
                                    {
                                        promise(.success(""))
                                    }
                                }.store(in: &self.cancellableSet)
                            }
                            else
                            {
                                promise(.success(""))
                            }
                        }.store(in: &self.cancellableSet)
                    }
                }.store(in: &self.cancellableSet)
            } catch {
                promise(.success(""))
            }
        }
    }
        
    
    /**
     신규로 생성된 wallet 닉모닉을 생성 합니다. ( J.D.H VER : 1.0.0 )
     - description: 웹에서 신규 wallet 생성후 정보를 받아 로컬에 파일로 저장 합니다. (/keystore.json)
     - Date: 2023.06.02
     - Parameters:
        - walletPass : 닉모닉 생성시 사용할 wallet 페스워드 입니다.
     - Throws: False
     - Returns:
        신규로 생성된 wallet 주소 + 개인키 를 리턴 합니다. (String?)
     */
    private func setCreateMnemonics( walletPass : String = "" ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            SharedDefaults.default.walletMnemonic = ""
            SharedDefaults.default.walletAddress  = ""
            let userDir             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore", scanForHDwallets: true, suffix: "json")
            let tcount              = web3KeystoreManager?.addresses?.count ?? 0
            do {
                /// 기존 파일 정보가 있다면 삭제 합니다.
                if tcount >= 1 { self.removeAllKeystorefiles(path: userDir + "/keystore") }
                if web3KeystoreManager?.addresses?.count ?? 0 >= 0
                {
                    let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english)
                    guard let tMnemonics = tempMnemonics else {
                        CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                        }
                        return
                    }
                    
                    let tempWalletAddressKeyStore = try? BIP32Keystore(mnemonics: tMnemonics, password: walletPass, mnemonicsPassword : walletPass, prefixPath: HDNode.defaultPath)
                    guard let walletAddress = tempWalletAddressKeyStore?.addresses?.first else {
                        CMAlertView().setAlertView(detailObject: "지갑을 생성할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                        }
                        return
                    }
     
                    let lowerWalletAddress      = walletAddress.address.lowercased()
                    let privateKey              = try tempWalletAddressKeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                    let keyData                 = try? JSONEncoder().encode(tempWalletAddressKeyStore?.keystoreParams)
                    let pForcedStr : String!    =  privateKey?.toHexString()
                    /// 월렛 관련 키스토어 폴더 여부를 체크 합니다.
                    self.isFolder().sink { success in
                        if success
                        {
                            /// 월렛 관련 키 파일을 추가 합니다.
                            self.addFile(keyData).sink { success in
                                if success
                                {
                                    SharedDefaults.default.walletMnemonic = tMnemonics
                                    SharedDefaults.default.walletAddress  = lowerWalletAddress
                                    Slog("create: mnemonics     = \(tMnemonics)", category: .wallet)
                                    Slog("create: password      = \(walletPass)", category: .wallet)
                                    Slog("create: address key   = \(lowerWalletAddress)", category: .wallet)
                                    Slog("create: private key   = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                                    promise(.success(lowerWalletAddress + ":" + pForcedStr))
                                }
                                else
                                {
                                    promise(.success(""))
                                }
                            }.store(in: &self.cancellableSet)
                        }
                        else
                        {
                            /// 월렛 관련 키스토어 폴더 를 생성 합니다.
                            self.addFolder().sink { success in
                                if success
                                {
                                    /// 월렛 관련 키 파일을 추가 합니다.
                                    self.addFile(keyData).sink { success in
                                        if success
                                        {
                                            SharedDefaults.default.walletMnemonic = tMnemonics
                                            SharedDefaults.default.walletAddress  = lowerWalletAddress
                                            Slog("create: mnemonics  = \(tMnemonics)", category: .wallet)
                                            Slog("create: password  = \(walletPass)", category: .wallet)
                                            Slog("create: address key  = \(lowerWalletAddress)", category: .wallet)
                                            Slog("create: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                                            promise(.success(lowerWalletAddress + ":" + pForcedStr))
                                        }
                                        else
                                        {
                                            promise(.success(""))
                                        }
                                    }.store(in: &self.cancellableSet)
                                }
                                else
                                {
                                    promise(.success(""))
                                }
                            }.store(in: &self.cancellableSet)
                        }
                    }.store(in: &self.cancellableSet)
                }
            } catch {
                promise(.success(""))
            }
        }
    }
    
    
    /**
     로컬 저장된 wallet 파일을 삭제 합니다. ( J.D.H VER : 1.0.0 )
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
     Encrypt 정보로 변경하여 리턴 합니다. ( J.D.H VER : 1.0.0 )
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
     지갑 복구를 요청 합니다. ( J.D.H VER : 1.0.0 )
     - description: 웹에서 복구 요청으로 받은 encinfo 정보와 유저가 입력한 닉모닉 정보를 받아 복구구분을 진행 복구된 지갑 정보를 리턴 합니다.
     - Date: 2023.06.20
     - Parameters:
        - encInfo : enc 정보를 받습니다.
        - mnemonic : 복구할 닉모닉 정보 입니다.
     - Throws: False
     - DispatchQueue: True
     - Returns:
        암호화된 ENC 정보를 리턴 합니다. Future<String?, Never>
     */
    func getRestoreWallet( encInfo : String = "", mnemonic : String = "" ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            /// 복호화된 password 를 가져 옵니다.
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                var privateKey : String? = nil
                DispatchQueue.global(qos: .userInteractive).async {
                    /// 복구된 지갑 정보를 가져 옵니다.
                    self.setWalletWithMnemonuc(walletPass: walletPass, mnemonics: mnemonic).sink(receiveValue: { wallet in
                        privateKey = wallet
                        DispatchQueue.main.async {
                            promise(.success(privateKey))
                        }
                    }).store(in: &self.cancellableSet)
                }
            } else { promise(.success("")) }
        }
    }
    
    
    /**
     로컬에 저장된 wallet 정보를 리턴 합니다. ( J.D.H VER : 1.0.0 )
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
                        promise(.success(""))
                    }
                    return
                }
                Slog("CheckExisting : walletAddress  = \(walletAddress.address)",category: .wallet)
                promise(.success(walletAddress.address))
            }
            else
            {
                promise(.success(""))
            }
        }
    }
    
    
    /**
     로컬에 저장된 Wallet 개인 키정보를 리턴 합니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
     - Throws: False
     - Returns:
        로컬 개인 키정보를 리턴 합니다. Future<String?, Never>
     */
    func getWalletPrivateKey( encInfo : String = "" )  -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                var privateKey : String? = nil
                DispatchQueue.global(qos: .userInteractive).async {
                    /// 신규로 저장된 Wallet 개인키 를 받습니다.
                    privateKey = self.getPrivateKey(walletPass: walletPass)
                    DispatchQueue.main.async {
                        if let privateKey = privateKey {
                            promise(.success(privateKey))
                        }
                        else
                        {
                            promise(.success(""))
                        }
                    }
                }
            }
            else
            {
                promise(.success(""))
            }
        }
    }
    
    
    /**
     로컬에 저장된 개인 키정보를 리턴 합니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.06.20
     - Parameters:
        - walletPass : 지갑 주소 정보를 받습니다.
     - Throws: False
     - Returns:
        로컬 개인 키정보를 리턴 합니다. (String?)
     */
    private func getPrivateKey( walletPass : String ) -> String? {
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
                return nil
            }
            do {
                let privateKey      = try web3KeyStore?.UNSAFE_getPrivateKeyData(password: walletPass, account: walletAddress)
                Slog("checkPrivate : walletAddress  = \(walletAddress)", category: .wallet)
                Slog("checkPrivate: private key  = \(String(describing: privateKey?.toHexString()))", category: .wallet)
                return privateKey?.toHexString()
            }
            catch
            {
                Slog(error, category: .wallet)
            }
            return nil
        }
        return nil
    }
    
    
    /**
     신규 생성된 지갑 정보를 로컬에 저장 합니다. ( J.D.H VER : 1.0.0 )
     - Description: 웹에서 신규 Wallet 생성후 정보를 받아 로컬에 파일로 저장 합니다. (/keystore.json) 저장후 주소 + 개인 키 정보를 리턴 합니다.
     - Date: 2023.06.02
     - Parameters:
        - encInfo : enc 정보를 받습니다.
     - Throws: False
     - DispatchQueue: True
     - Returns:
        저장후 wallet 주소를 리턴 합니다. Future<String?, Never>
     */
    func setCreateWalletToAddrKey( encInfo:String ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            /// 복호화된 password 를 가져 옵니다.
            if let walletPass = self.getDecryptedWalletPasswdFromInfo(encInfo) {
                DispatchQueue.global(qos: .userInteractive).async {
                    /// 신규로 저장된 Wallet 주소+ 개인키 를 받습니다.
                    self.setCreateMnemonics( walletPass: walletPass ).sink { walletAddrKey in
                        DispatchQueue.main.async {
                            promise(.success(walletAddrKey))
                        }
                    }.store(in: &self.cancellableSet)
                }
            } else { promise(.success("")) }
        }
    }
    
    
    /**
     폴더 존재 여부를 체크 합니다.
     - Date: 2023.05.22
     - Parameters:
        - folderName : 폴더명 입니다.
     - Throws:False
     - returns:
        폴더 존재 여부를 리턴 합니다. Future<Bool, Never>
     */
    func isFolder( folderName : String = WalletViewModel.defaultFolder ) -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 기본 디렉토리 정보를 가져 옵니다.
            var dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            /// 가져온 디렉토리 정보가 있는지를 체크 합니다.
            if dirPaths.count > 0
            {
                /// 폴더명을 추가합니다.
                dirPaths[0].append(folderName)
                /// 해당 폴더 여부를 체크 합니다.
                if FileManager.default.fileExists(atPath: dirPaths[0] as String)
                {
                    promise(.success(true))
                }
                else
                {
                    promise(.success(false))
                }
            }
            else
            {
                promise(.success(false))
            }
        }
    }
    
    
    /**
    폴더를 생성 합니다.
     - Date: 2023.05.22
     - Parameters:
        - folderName : 폴더명 입니다. ( default : "/keystore" )
     - Throws:False
     - Returns:
        폴더 생성 정상처리 여부를 리턴 합니다. ( Future<Bool, Never> )
     */
    func addFolder( folderName : String = WalletViewModel.defaultFolder ) -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 기본 디렉토리 정보를 가져 옵니다.
            var dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            /// 폴더명을 추가합니다.
            dirPaths[0].append(folderName)
            let dirPath = dirPaths[0] as String
            /// 폴더가 존재 하는지를 체크 합니다.
            if FileManager.default.fileExists(atPath: dirPath)
            {
                promise(.success(true))
            }
            else
            {
                do {
                    /// 신규 폴더를 생성 합니다.
                    try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                    promise(.success(true))
                } catch {
                    promise(.success(false))
                }
            }
        }
    }
    
    
    /**
     파일에 object 데이터를 추가 합니다.
     - Date: 2023.05.22
     - Parameters:
        - object : 파일에 추가할 NSObject 데이터 정보 입니다.
     - Throws:False
     - DispatchQueue:.global.qos.userInitiated
     - Returns:
        파일 작성 정상처리 여부 리턴 힙니다. Future<Bool, Never>
     */
    func addFile( _ object : Any? ) -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            let userDir   = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath  = userDir + "/keystore/key.json"
            var isWrite : Bool = false
            DispatchQueue.global(qos: .userInitiated).async {
                isWrite = FileManager.default.createFile(atPath: filePath, contents: object as? Data, attributes: nil)
                Slog("addFile isWrite : \(isWrite)",category: .wallet)
                DispatchQueue.main.async {
                    promise(.success(isWrite))
                }
            }
        }
    }
    
}

