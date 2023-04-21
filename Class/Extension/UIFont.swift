//
//  UIFont.swift
//  MyData
//
//  Created by dyjung on 2022/02/07.
//

import UIKit

extension UIFont {
    class func Roboto(type: RobotoType, size: CGFloat) -> UIFont! {
        guard let font = UIFont(name: type.name, size: size) else {
            return nil
        }
        return font
    }

    public enum RobotoType {
        case BlackItalic
        case Black
        case BoldItalic
        case Bold
        case MediumItalic
        case Medium
        case Italic
        case Regular
        case LightItalic
        case Light
        case ThinItalic
        case Thin

        var name: String {
            switch self {
            case .BlackItalic:
                return "Roboto-BlackItalic"
            case .Black:
                return "Roboto-Black"
            case .BoldItalic:
                return "Roboto-BoldItalic"
            case .Bold:
                return "Roboto-Bold"
            case .MediumItalic:
                return "Roboto-MediumItalic"
            case .Medium:
                return "Roboto-Medium"
            case .Italic:
                return "Roboto-Italic"
            case .Regular:
                return "Roboto-Regular"
            case .LightItalic:
                return "Roboto-LightItalic"
            case .Light:
                return "Roboto-Light"
            case .ThinItalic:
                return "Roboto-ThinItalic"
            case .Thin:
                return "Roboto-Thin"
            }
        }
    }
    
    class func NotoSansKr(type: NotoSansKrType, size: CGFloat) -> UIFont! {
        guard let font = UIFont(name: type.name, size: size) else {
            return nil
        }
        return font
    }

    public enum NotoSansKrType {
        case Black
        case Bold
        case Medium
        case Regular
        case Light
        case Thin
        
        var name: String {
            switch self {
            case .Black:
                return "NotoSansKR-Black"
            case .Bold:
                return "NotoSansKR-Bold"
            case .Medium:
                return "NotoSansKR-Medium"
            case .Regular:
                return "NotoSansKR-Regular"
            case .Light:
                return "NotoSansKR-Light"
            case .Thin:
                return "NotoSansKR-Thin"
            }
        }
    }
}
