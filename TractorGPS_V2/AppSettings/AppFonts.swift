//
//  AppFonts.swift
//  Baby Tracker
//
//  Created by QTS Coder on 21/3/25.
//
import SwiftUI

struct AppFonts {
    static func bold(size: CGFloat) -> Font {
        return Font.custom("SFProText-Bold", size: size)
    }
    
    static func regular(size: CGFloat) -> Font {
        return Font.custom("SFProText-Regular", size: size)
    }
    
    static func medium(size: CGFloat) -> Font {
        return Font.custom("SFProText-Medium", size: size)
    }
    
    static func semiBold(size: CGFloat) -> Font {
        return Font.custom("SFProText-Semibold", size: size)
    }
    
    static func light(size: CGFloat) -> Font {
        return Font.custom("SFProText-Light", size: size)
    }
}
