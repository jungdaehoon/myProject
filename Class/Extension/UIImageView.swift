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
     이미지를 육각형으로 설정 합니다.
     - Date: 2023.07.05
     - Parameters:
        - rect : 육각형 영역을 설정할 전체 영역을 받습니다.
     - Throws:False
     - Returns:
        육각형 영역 설정된 path 정보를 리턴 합니다. (UIBezierPath?)
     */
    func setHexagonImage(){
        if let path = self.setHexagon(rect: CGRect(x: 8, y: 8, width: self.frame.size.width - 16, height: self.frame.size.height - 16)) {
            let drawinglayer   = CAShapeLayer()
            drawinglayer.frame = CGRect(origin: CGPoint(x: 8, y: 8), size:.zero)
            drawinglayer.path  = path.cgPath
            self.layer.mask    = drawinglayer
        }
    }
    
    
    /**
     육각형 영역을 설정 합니다.
     - Date: 2023.07.05
     - Parameters:
        - rect : 육각형 영역을 설정할 전체 영역을 받습니다.
     - Throws:False
     - Returns:
        육각형 영역 설정된 path 정보를 리턴 합니다. (UIBezierPath?)
     */
    func setHexagon( rect : CGRect ) -> UIBezierPath?{
        let path = UIBezierPath(rect: rect)
        UIColor.lightGray.setFill()
        path.fill()
        path.close()

        let pentagonPath = UIBezierPath()

        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width/2, y: height/2)

        let sides = 6
        let cornerRadius: CGFloat = 1
        let rotationOffset = CGFloat(Double.pi / 2.0)
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides)
        let radius = (width + cornerRadius - (cos(theta) * cornerRadius)) / 2.0

        var angle = CGFloat(rotationOffset)

        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        pentagonPath.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        for _ in 0 ..< sides {
            angle += theta
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            pentagonPath.addLine(to: start)
            pentagonPath.addQuadCurve(to: end, controlPoint: tip)
        }

        var pathTransform  = CGAffineTransform.identity
        pathTransform = pathTransform.translatedBy(x: 0, y: -(rect.height-pentagonPath.bounds.height)/2)
        pentagonPath.apply(pathTransform)

        UIColor.black.set()
        pentagonPath.stroke()
        pentagonPath.close()
        return pentagonPath
    }
    
}
