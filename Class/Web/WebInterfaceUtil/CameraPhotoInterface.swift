//
//  CameraPhotoInterface.swift
//  cereal
//
//  Created by srkang on 2018. 8. 14..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices


class  CameraPhotoInterface : NSObject {
    
    static let COMMAND_CAPTURE_AND_SAVE_OMAGE = "captureAndSaveImage" // 현재 웹뷰를 캡쳐해서 사진(갤러리) 앱에 저장
    static let COMMAND_GETIMAGE_FROM_GALLERY  = "getImageFromGallery" // 사진(갤러리)앱에서 사진을 선택해서 프로필 사진으로 서버에 전송
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("ContactInterface")
    }
}


extension CameraPhotoInterface :  HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        
        let action = command[1] as! String
        
        
        
        if action == CameraPhotoInterface.COMMAND_CAPTURE_AND_SAVE_OMAGE {
           /*
            // 캡쳐 이미지를 갤러리에 저장
            
            if let permissionScope = ApplicationShare.shared.permissionInfo.permissionScope {
                
                permissionScope.statusPhotos(completion: { (status) in
                    permissionScope.onAuthChange = { (allSuccess, permissionResults ) in
                        log?.debug("CameraPhotoInterface onAuthChange called-1")
                    }
                    
                    if status == .unknown {
                        // 사진 접근 권한 요청을 한 적이 없을 경우 권한 요청을 한다.
                        permissionScope.requestPermission(type: .photos, permissionResult: { (finished, permissionResult,error) in
                            
                            if error == nil && permissionResult?.status == .authorized {
                                self.captureWebView()
                            } else if permissionResult?.status == .unauthorized {
                                permissionScope.showDeniedAlert(viewController: viewController, permission: .photos)
                            }
                            
                        })
                    } else if status == .authorized {
                        // 사진 접근이 허가 된 경우, 현재 화면을 캡쳐해서 사진앱에 저장한다.
                        self.captureWebView()
                    } else if status == .unauthorized {
                        // 사진 접근이 거절 된 경우, 권한이 필요하다는 Alert 을 보여준다.
                        permissionScope.showDeniedAlert(viewController: viewController, permission: .photos)
                    }
                    
                    
                })
            }*/
        }  else if action == CameraPhotoInterface.COMMAND_GETIMAGE_FROM_GALLERY {
            // 갤러리를 선택해서 프로필 이미지 전송
            /*
            if let permissionScope = ApplicationShare.shared.permissionInfo.permissionScope {
                
                permissionScope.statusPhotos(completion: { (status) in
                    
                    permissionScope.onAuthChange = { (allSuccess, permissionResults ) in
                        log?.debug("CameraPhotoInterface onAuthChange called-1")
                    }
                    
                    if status == .unknown {
                        
                        permissionScope.requestPermission(type: .photos, permissionResult: { (finished, permissionResult,error) in
                            
                            if error == nil && permissionResult?.status == .authorized {
                                self.getImageFromGallerySendServer()
                            } else if permissionResult?.status == .unauthorized {
                                permissionScope.showDeniedAlert(viewController: viewController, permission: .photos)
                            }
                            
                        })
                    } else if status == .authorized {
                        self.getImageFromGallerySendServer()
                    } else if status == .unauthorized {
                        permissionScope.showDeniedAlert(viewController: viewController, permission: .photos)
                    }
                    
                })
            }*/
        }
        
        
    }// command
    
    
    func captureAndSaveImage() {
        
        if let webViewController =  viewController as? BaseViewController ,
          let webView = webViewController.webView {
            
            webView.swContentCapture({ (capturedImage) -> Void in
                
                UIImageWriteToSavedPhotosAlbum(capturedImage!, self, nil, nil)
            })
        }
    }
    
    func getImageFromGallerySendServer() {
        
       self.showImagePicker(type: .photoLibrary)
    }
    
    func showImagePicker(type : UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.mediaTypes = [ kUTTypeImage as String]
        
        picker.delegate = self
        
        picker.allowsEditing = true // try true
        
        
        viewController.present(picker, animated: true)
        
    }
    
    // 웹뷰를 캡쳐해서 , 사진앱에 저장한다.
    func captureWebView() {
        
        if let webViewController =  viewController as? BaseViewController ,
            let webView = webViewController.webView {
            
            let currentSize = webView.frame.size
            let currentOffset = webView.scrollView.contentOffset
            
            webView.frame.size = webView.scrollView.contentSize
            
            var contentOffset : CGPoint = .zero
            
            if #available(iOS 11, *) {
                contentOffset = CGPoint(x: 0, y: -webView.scrollView.adjustedContentInset.top)
            } else {
                contentOffset = CGPoint(x: 0,y: -webView.scrollView.contentInset.top)
            }
            
            webView.scrollView.setContentOffset(contentOffset, animated: false)
            
//            webView.scrollView.setContentOffset(currentOffset, animated: false)
            
            let rect = CGRect(x: 0, y: 0, width: webViewController.view.bounds.size.width, height: webViewController.view.bounds.size.height)
            
//            delay(0.3) {
                UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
                // iOS7
                webView.drawHierarchy(in: rect, afterScreenUpdates: true)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                webView.frame.size = currentSize
                webView.scrollView.setContentOffset(currentOffset, animated: false)
                
                
                guard image != nil else {
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)),nil)
//            }
            
           
        
        } else {
            self.resultCallback( HybridResult.success(message: "false" ))
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.resultCallback( HybridResult.success(message: "false" ))
        } else {
           self.resultCallback( HybridResult.success(message: "true" ))
        }
    }
    
    
    // 선택한 이미지를 서버에 전송
    func btnSendServerAction(image : UIImage) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            //log?.debug("Could not get JPEG representation of UIImage")
            return
        }
        
        //let keyChainWrapper = ApplicationShare.shared.keychainWrapper
        let custItem = SharedDefaults.getKeyChainCustItem()
        
        // Multi-part 형태로 보낸다.
        AlamofireAgent.upload("api/uploadImg.do", multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData,  withName: "file", fileName: "fileName.jpg", mimeType: "image/jpeg")
            multipartFormData.append(custItem!.user_no!.data(using: .utf8)!, withName: "user_no")
        },
        encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    
                    //log?.debug(progress.fractionCompleted)
                    //progressCompletion(Float(progress.fractionCompleted))
                }
                
                _ = upload.log()
                
                
                upload.response(completionHandler: { (defaultData) in
                    if let data =  defaultData.data {
                        let responseData = String(data: data, encoding: .utf8)
                        //log?.debug(defaultData.response?.statusCode as Any)
                        //log?.debug(responseData as Any)
                    }
                })
                
                upload.responseJSON { response in
                    guard response.result.isSuccess else {
                        //log?.debug("Error while uploading file: \(String(describing: response.result.error))")
                        self.resultCallback( HybridResult.success(message: "false" ))
                        return
                    }
                    
                    /*
                    {
                        "msg" : "정상적으로 처리되었습니다.",
                        "data" : {
                            "url" : "https:\/\/m.mycereal.co.kr:8443\/matcs\/resources\/upload\/USERIMGUPLOAD\/TUA00002\/0000016584ea198c0004a1ad8b130f28.jpg"
                        },
                        "code" : "0000"
                    }
                    https:\/\/m.mycereal.co.kr:8443\/matcs\/resources\/upload\/USERIMGUPLOAD\/TUA00002\/0000016584ea198c0004a1ad8b130f28.jpg
                    */
                    
                    if let value = response.result.value as? [String:Any] {
                    
                        if let data = value["data"] as? [String:Any] {
                            if let url = data["url"] as? String {
                                //Notification.Name.PhotoChange.post(object: nil, userInfo: ["url" : url])
                                self.resultCallback( HybridResult.success(message: ["true", url]    ))
                            } else {
                                self.resultCallback( HybridResult.success(message: "false" ))
                                return
                            }
                        }
                    } else {
                        self.resultCallback( HybridResult.success(message: "false" ))
                        return
                    }
                }
                
            case .failure(let encodingError):
                //log?.debug(encodingError)
                self.resultCallback( HybridResult.success(message: "false" ))
                return
            }
        })
        
    }
    
    
}


extension CameraPhotoInterface : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated:true)
    }
    //JJBAE MODIFIED FOR UPGRADE SWIFT VERSION
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[.originalImage] as? UIImage
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected dictionary containing an image, but was provided the following: \(info)")
        }
        image = selectedImage
        
        viewController.dismiss(animated:true) {
            let mediaType = info[.mediaType]
                    guard let type = mediaType as? NSString else {return}
                    switch type as CFString {
                    case kUTTypeImage:
                        // 선택한 이미지를 서버에 전송
                        self.btnSendServerAction(image: image!)
                    default:
                        ()
                    }
                }
    }
    
    //JJBAE MODIFIED FOR UPGRADE SWIFT VERSION
    /*func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        var image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            image = editedImage
        }
//        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            image = editedImage
//        }
        
        viewController.dismiss(animated:true) {
            let mediaType = info[UIImagePickerController.InfoKey.mediaType.rawValue]
//            let mediaType = info[UIImagePickerControllerMediaType]
            
            guard let type = mediaType as? NSString else {return}
            switch type as CFString {
            case kUTTypeImage:
                // 선택한 이미지를 서버에 전송
                self.btnSendServerAction(image: image!)
            default:
                ()
            }
            
        }
    }*/
    
}

