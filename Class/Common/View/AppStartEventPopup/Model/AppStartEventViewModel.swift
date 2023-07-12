//
//  AppStartEventViewModel.swift
//  cereal
//
//  Created by OKPay on 2023/07/12.
//

import Foundation
import Combine


/**
 앱 시작시 이벤트 뷰 모델 입니다.    ( J.D.H  VER : 1.0.0 )
 - Date: 2023.07.12
 */
class AppStartEventViewModel : BaseViewModel{
    
    
    /**
     이벤트 이미지 기준으로 디스플레이 할 이미지 사이즈를 받습니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.07.12
     - Parameters:
        - image               : 디스플레이 할 원본 이미지 입니다.
        - displaySize  : 디스플레이 할 원본 사이즈 영역 입니다.
     - Throws: False
     - Returns:
        디스플레이 할 변경된 사이즈를 받습니다. (Future<CGSize?, Never>)
     */
    func getEventImageDisplaySize( image : UIImage, displaySize: CGSize) -> Future<CGSize?, Never>
    {
        return Future<CGSize?, Never> { promise in
            let displayWidth    = displaySize.width
            let height          = CGFloat(image.cgImage!.height)
            let width           = CGFloat(image.cgImage!.width)
            let displayHeight   = CGFloat(displayWidth * height / width)
            promise(.success(CGSize(width: displayWidth, height: displayHeight)))
        }
    }
    
}
