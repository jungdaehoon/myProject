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
 송금 웹뷰 모델 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.22
*/
class WalletViewModel : BaseViewModel{
    let encKey  = "CpUzZ08BAcn46Ie1"
    let endIv   = "tPAG8Ru1SS5qjyEo"
    
    var keyManager : KeystoreManager? {
        get {
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let path = userDir+"/keystore"
            return KeystoreManager.managerForPath(path)
        }
    }
    
    
    func getEncryptWData( message: String, key: String, iv: String ) -> Future<String?, Never>
    {
        return Future<String?, Never> { promise in
            do{
                let data = message.data(using: .utf8)!
                // let enc = try AES(key: key, iv: iv, padding: .pkcs5).encrypt([UInt8](data))
                let enc = try AES(key: Array(key.utf8), blockMode: CBC(iv: Array(iv.utf8)), padding: .pkcs5).encrypt([UInt8](data))
                let encryptedData = Data(enc)
                promise(.success(encryptedData.base64EncodedString()))
            }catch{
                promise(.success(""))
            }
        }
    }
    
    
    func getDecryptWData( encryptedData: String, key: String, iv: String ) -> Future<String?, Never>
    {
        return Future<String?, Never> { promise in
            do{
                let data = NSData(base64Encoded: encryptedData, options: NSData.Base64DecodingOptions(rawValue: 0))!
                let dec = try AES(key: key, iv: iv, padding: .pkcs5).decrypt([UInt8](data))
                let decryptedData = Data(dec)
                let dataStr = String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
                promise(.success(dataStr))
            }catch{
                promise(.success(""))
            }
        }
    }
    
    
    func getMakeEncryptString( orgStr : String ) -> Future<String?, Never>
    {
        return Future<String?, Never> { promise in
            self.getEncryptWData( message: orgStr, key: self.encKey, iv: self.endIv).sink { value in
                if let encInfo = value
                {
                    promise(.success(encInfo))
                }
                else
                {
                    promise(.success(""))
                }
            }.store(in: &self.cancellableSet)
        }
    }
    
    
    func getRestoreWallet( encInfo:String, mnemonic:String ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            self.getDecryptWData(encryptedData: encInfo, key: self.encKey, iv: self.endIv).sink { value in
                if let walletPass = value
                {
                    let password = walletPass + "0kbc"
                    do{
                        if let twalletAddressKeyStore   = try? BIP32Keystore(mnemonics: mnemonic, password: password, mnemonicsPassword : password, prefixPath: HDNode.defaultPath),
                           let addresss                 = twalletAddressKeyStore.addresses,
                           let ethereumAddress          = addresss.first
                        {
                            let addrStr     = ethereumAddress.address
                            let privateKey  = try twalletAddressKeyStore.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
                            Slog("import: mnemonics  = \(mnemonic)")
                            Slog("import: password  = \(password)")
                            Slog("import: address  = \(addrStr)")
                            Slog("import: private key  = \(String(describing: privateKey.toHexString()))")
                            
                            if let param = twalletAddressKeyStore.keystoreParams
                            {
                                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                let keyData = try? JSONEncoder().encode(param)
                                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                                SharedDefaults.default.walletMnemonic = mnemonic
                                promise(.success("\(addrStr)"))
                            }
                        }
                        else
                        {
                            promise(.success(""))
                        }
                    }catch{
                        promise(.success(""))
                    }
                }
                else
                {
                    promise(.success(""))
                }
            }.store(in: &self.cancellableSet)
        }
    }
    
    
    func setCreateWallet( encInfo:String ) -> Future<String?, Never> {
        return Future<String?, Never> { promise in
            self.getDecryptWData(encryptedData: encInfo, key: self.encKey, iv: self.endIv).sink { value in
                if let walletPass = value
                {
                    let password = walletPass + "0kbc"
                    do{
                        if let ketManager               = self.keyManager,
                           let keyAddress               = ketManager.addresses,
                           keyAddress.count > 0,
                           let tempMnemonics            = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: .english),
                           let twalletAddressKeyStore   = try? BIP32Keystore(mnemonics: tempMnemonics, password: password, mnemonicsPassword : password, prefixPath: HDNode.defaultPath),
                           let addresss                 = twalletAddressKeyStore.addresses,
                           let walletAddress            = addresss.first
                        {
                            let privateKey = try twalletAddressKeyStore.UNSAFE_getPrivateKeyData(password: password, account: walletAddress)
                            if let param = twalletAddressKeyStore.keystoreParams
                            {
                                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                let keyData = try? JSONEncoder().encode(param)
                                FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                                
                                promise(.success("\(walletAddress.address + ":" + privateKey.toHexString())"))
                            }
                        }
                    }catch{
                        promise(.success(""))
                    }
                }
                else
                {
                    promise(.success(""))
                }
            }.store(in: &self.cancellableSet)
        }
    }
    
    
    
    func isIfSameMnemonic( typedMnemonic : String? ) -> Future<Bool, Never> {
        return Future<Bool, Never> { promise in
            if let Mnemonic = typedMnemonic
            {
                let refindedMnemonic    = Mnemonic.trimmingCharacters(in: .whitespaces)
                if SharedDefaults.default.walletMnemonic.compare(refindedMnemonic, options: .caseInsensitive) == .orderedSame
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
    
}
