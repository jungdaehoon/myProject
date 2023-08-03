//
//  UIImage+.swift
//  mNote
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit

extension UIImage
{
    /**
     이미지를 원하는 사이즈로 리사이징 하여 리턴 합니다. ( J.D.H VER : 1.24.43 )
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
     이미지 사이즈를  높이 기준으로 조정 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.08.02
     - parameters:
        - newHeight : 이미지를 높이 기준으로 리사이징 합니다.
        - upScale : 이미지 퀄리티  업 스케일 정보 입니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func resize(newHeight: CGFloat, upScale : CGFloat = 1.0 ) -> UIImage {
        let scale           = newHeight / self.size.height
        let newWidth        = self.size.width * scale
        let size            = CGSize(width: newWidth, height: newHeight)
        let format          = UIGraphicsImageRendererFormat()
        format.scale        = upScale
        let renderer        = UIGraphicsImageRenderer(size: size, format: format)
        let renderImage     = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    /**
     이미지 사이즈를  넓이 기준으로 조정 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.08.02
     - parameters:
        - newWidth : 이미지를 넓이 기준으로 리사이징 합니다.
        - upScale : 이미지 퀄리티  업 스케일 정보 입니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func resize(newWidth: CGFloat, upScale : CGFloat = 1.0 ) -> UIImage {
        let scale           = newWidth / self.size.width
        let newHeight       = self.size.height * scale
        let size            = CGSize(width: newWidth, height: newHeight)
        
        let format          = UIGraphicsImageRendererFormat()
        format.scale        = upScale
        let renderer        = UIGraphicsImageRenderer(size: size, format: format)
        let renderImage     = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    
    /**
     이미지 Pix 사이즈를 조정 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.08.02
     - parameters:
        - newHeight : 이미지를 높이 기준으로 리사이징 합니다.
        - upScale : 이미지 퀄리티  업 스케일 정보 입니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func rePixsize(newHeight: CGFloat, upScale : CGFloat = 0.0 ) -> UIImage {
        let scale           = newHeight / CGFloat(self.cgImage!.height)
        let format          = UIGraphicsImageRendererFormat()
        format.scale        = scale
        let renderer        = UIGraphicsImageRenderer(size: self.size, format: format)
        let renderImage     = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    /**
     이미지를 넓이 기준으로 리사이징 하여 리턴 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.26
     - parameters:
        - newWidth : 이미지를 넓이 기준으로 리사이징 합니다.
        - upScale : 이미지 퀄리티  업 스케일 정보 입니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func rePixSize(newWidth: CGFloat, upScale : CGFloat = 0.0 ) -> UIImage {
        let scale           = newWidth / CGFloat(self.cgImage!.width)
        let format          = UIGraphicsImageRendererFormat()
        format.scale        = scale
        let renderer        = UIGraphicsImageRenderer(size: self.size, format: format)
        let renderImage     = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    
    /**
     회전된 이미지를 계산하여 리턴 합니다. ( J.D.H VER : 1.24.43 )
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



