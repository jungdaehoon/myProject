//
//  NSMutableAttributedString.swift
//  MyData
//
//  Created by INTAEK HAN on 2022/03/17.
//

import Foundation
import UIKit

extension NSMutableAttributedString {

    var fontSize: CGFloat {
        return 14
    }
    
    var notoBoldFont: UIFont {
        return UIFont.NotoSansKr(type: .Bold, size: fontSize)
    }
    
    var notoRegularFont: UIFont {
        return UIFont.NotoSansKr(type: .Regular, size: fontSize)
    }
    
    var robotoBoldFont: UIFont {
        return UIFont.Roboto(type: .Bold, size: fontSize)
    }
    
    var robotoMediumFont: UIFont {
        return UIFont.Roboto(type: .Medium, size: fontSize)
    }
    
    var robotoRegularFont: UIFont {
        return UIFont.Roboto(type: .Regular, size: fontSize)
    }

    func notoBold(string: String, fontSize: CGFloat, textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.NotoSansKr(type: .Bold, size: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor:textColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func notoRegular(string: String, fontSize: CGFloat, textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.NotoSansKr(type: .Regular, size: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor:textColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func robotoBold(string: String, fontSize: CGFloat, textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.Roboto(type: .Bold, size: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor:textColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func robotoMedium(string: String, fontSize: CGFloat, textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.Roboto(type: .Medium, size: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor:textColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func robotoRegular(string: String, fontSize: CGFloat, textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.Roboto(type: .Regular, size: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor:textColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func underlined(_ value:String,fontSize:CGFloat,textColor:UIColor) -> NSMutableAttributedString {
        let font:UIFont = UIFont.NotoSansKr(type: .Regular, size: fontSize)
        let attributes:[NSAttributedString.Key:Any] = [.font: font,
                                                        .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                       .foregroundColor: textColor]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func cancelLine(_ value:String,fontSize:CGFloat,textColor:UIColor) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString().robotoMedium(string: value, fontSize: fontSize, textColor: textColor)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
