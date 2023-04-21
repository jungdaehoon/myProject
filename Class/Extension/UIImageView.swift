//
//  UIImageView.swift
//  MyData
//
//  Created by daehoon on 2022/04/04.
//

import UIKit
import Combine
import Alamofire


extension UIImageView {
    
    /**
     이미지를 다운로드 하여 리턴 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2022.04.04
     - Parameters:
        - url : 이미지 url 정보를 받습니다.
     - Throws : False
     - returns :
        - AnyPublisher<UIImage?, Never>
            : UIImage 이미지 정보를 받습니다.
     */
    static func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
    {
        let subject             = PassthroughSubject<UIImage?,Never>()
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileManager     = FileManager.default
            var documentsURL    = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("temp")
            var isDir : ObjCBool = false
            if fileManager.fileExists(atPath: documentsURL.path, isDirectory: &isDir) {}
            else
            {
                do {
                    try fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
                } catch { }
            }
            documentsURL.appendPathComponent("profile.jpg")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
            print("Progress: \(progress.fractionCompleted)")
        } .validate().responseData { ( response ) in
            if let destinationURL = response.destinationURL {
                if let data = try? Data(contentsOf: destinationURL) {
                    subject.send(UIImage(data: data))
                }
                else
                {
                    subject.send(nil)
                }
            }
            else
            {
                subject.send(nil)
            }
        }        
        return subject.eraseToAnyPublisher()
    }
     
    
}
