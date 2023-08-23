//
//  UIButton.swift
//  MyData
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit
import Combine
import Alamofire

extension UIButton {
    /**
     이미지를 다운로드 하여 리턴 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.04
     - Parameters:
        - url : 이미지 url 정보를 받습니다.
     - Throws: False
     - Returns:
        UIImage 이미지 정보를 받습니다. (AnyPublisher<UIImage?, Never>)
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
            Slog("Progress: \(progress.fractionCompleted)")
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
    
    /**
     컬러정보를 받아 이미지로 적용 합니다. ( on/off 타입에 주로 사용 ) ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.09
     - Parameters:
        - color : 적용할 컬러 타입입니다.
        - state : 버튼 타입 입니다.
     - Throws: False
     - Returns:False
     */
    func setBackgroundColorToImage(_ color: UIColor?, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color?.cgColor ?? UIColor.white.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(backgroundImage, for: state)
    }
}
