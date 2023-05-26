//
//  UIImage+.swift
//  mNote
//
//  Created by daehoon on 2022/08/08.
//

import UIKit

extension UIImage
{
    /**
     이미지를 원하는 사이즈로 리사이징 하여 리턴 합니다.
     - Date: 2023.04.26
     - parameters:
        - size : 이미지를 넓이 기준으로 리사이징 합니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func resize( size : CGSize) -> UIImage {
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    /**
     이미지를 넓이 기준으로 리사이징 하여 리턴 합니다.
     - Date: 2023.04.26
     - parameters:
        - newWidth : 이미지를 넓이 기준으로 리사이징 합니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    /**
     회전된 이미지를 계산하여 리턴 합니다.
     - Date: 2023.04.26
     - parameters:
        - radians : 회전 각도 값입니다. ( CGFloat(angle * .pi) / 180 as CGFloat 설정된 값 )
     - Throws:False
     - returns:False
    */
    public func rotate( _ radians : CGFloat) -> UIImage
    {
        var newSize         = CGRect(origin: .zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width  = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        let format          = UIGraphicsImageRendererFormat()
        format.scale        = UIScreen.main.scale * 3
        let renderer        = UIGraphicsImageRenderer(size: newSize, format: format)
                
        return renderer.image { renderer in
            let context = renderer.cgContext
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            context.rotate(by: radians)
            context.setFillColor(UIColor.clear.cgColor)
            draw(in: CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: size))
        }
    }
    
}



