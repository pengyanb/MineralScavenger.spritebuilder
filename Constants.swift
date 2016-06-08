//
//  Constants.swift
//  MatchOnDemand
//
//  Created by Yanbing Peng on 9/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

enum TILT_DIRECTION{
    case LEFT(Double)
    case RIGHT(Double)
    case CENTER(Double)
    
    func toString()->String{
        switch self{
        case .LEFT: return "Left"
        case .RIGHT: return "Right"
        case .CENTER: return "Center"
        }
    }
    
    func getTiltAngle()->Double{
        switch self{
        case .LEFT(let angle): return angle;
        case .RIGHT(let angle): return angle;
        case .CENTER(let angle): return angle;
        }
    }
}

enum MATCHING_CRITERIA : Int{
    case SHAPE = 0
    case COLOR = 1
    case NUMBER = 2
    
    func toString()->String{
        switch self{
        case .SHAPE: return "SHAPE"
        case .COLOR: return "COLOR"
        case .NUMBER: return "NUMBER"
        }
    }
}

enum SOUND_EFFECT {
    case SOUND_BLOP
    case SOUND_JUMPING
    case SOUND_LEVEL_UP1
    case SOUND_LEVEL_UP2
    case SOUND_SHATTERING
    
    func toString()->String{
        switch self{
        case .SOUND_BLOP: return "Blop.wav"
        case .SOUND_JUMPING: return "Jumping.wav"
        case .SOUND_LEVEL_UP1: return "LevelUp1.wav"
        case .SOUND_LEVEL_UP2: return "LevelUp2.wav"
        case .SOUND_SHATTERING: return "Shattering.wav"
        }
    }
}

enum CONSTANTS_ENUM{
    
    case ENUM_SPRITE_FILE_NAME(String)
    
    case ENUM_ASSERT_VISUAL_SHAPE_PATH(String)
    
    case ENUM_SPRITE_FOLDER(String)
    
    case ENUM_SPRITE_SHAPE_COLOR(String)
    
    case ENUM_SPRITE_NUMBER(String)
    
    case ENUM_STORE_ITEM_IDENTIFIER(String)
    
    func getAssociatedString()->String{
        switch self{
        case let .ENUM_SPRITE_FILE_NAME(fileNameIdentifier) : return fileNameIdentifier
        case let .ENUM_ASSERT_VISUAL_SHAPE_PATH(pathIdentifier) : return pathIdentifier
        case let .ENUM_SPRITE_FOLDER(folderIdentifier) : return folderIdentifier
        case let .ENUM_SPRITE_SHAPE_COLOR(colorIdentifier) : return colorIdentifier
        case let .ENUM_SPRITE_NUMBER(numIdentifier) : return numIdentifier
        case let .ENUM_STORE_ITEM_IDENTIFIER(itemIdentifier): return itemIdentifier
        }
    }
}

struct CONSTANTS{
    //NSUserDefaultKey
    static let NSUSER_DEFAULT_KEY = "com.pengyanb.MineralScavenger.NsUserDefaultsKey"
    //STORE item IDENTIFIER
    static let STORE_ITEM_IDENTIFIER1 = CONSTANTS_ENUM.ENUM_STORE_ITEM_IDENTIFIER("com.pengyanb.MineralScavenger.RemoveAds")
    
    //AdMob 
    static let ADMOB_BANNER_ADUNITID = "ca-app-pub-3199275288482759/5946606621"
    static let ADMOB_INTERSTitial_ADUNITID = "ca-app-pub-3199275288482759/7423339827"
    
    //Shape File Name
    static let SPRITE_FILE_NAME_CIRCLE = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/CircleSprite")
    static let SPRITE_FILE_NAME_HEART = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/HeartSprite")
    static let SPRITE_FILE_NAME_OVAL = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/OvalSprite")
    static let SPRITE_FILE_NAME_PENTAGON = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/PentagonSprite")
    static let SPRITE_FILE_NAME_RECTANGLE = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/RectangleSprite")
    static let SPRITE_FILE_NAME_SQUARE = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/SquareSprite")
    static let SPRITE_FILE_NAME_STAR = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/StarSprite")
    static let SPRITE_FILE_NAME_TRIANGLE = CONSTANTS_ENUM.ENUM_SPRITE_FILE_NAME("Sprites/TriangleSprite")
    
    //Assert visual Shape Path
    static let PATH_SHAPES = CONSTANTS_ENUM.ENUM_ASSERT_VISUAL_SHAPE_PATH("Asserts/Visual/Shapes/")
    
    //Shape Path
    static let SPRITE_CIRCLE_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Circle/")
    static let SPRITE_HEART_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Heart/")
    static let SPRITE_OVAL_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Oval/")
    static let SPRITE_PENTAGON_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Pentagon/")
    static let SPRITE_RECTANGLE_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Rectangle/")
    static let SPRITE_SQUARE_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Square/")
    static let SPRITE_STAR_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Star/")
    static let SPRITE_TRIANGLE_FOLDER = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Triangle/")
    
    //Shape Color
    static let COLOR_BLUE = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Blue.png")
    static let COLOR_CYAN = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Cyan.png")
    static let COLOR_GREEN = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Green.png")
    static let COLOR_ORANGE = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Orange.png")
    static let COLOR_PINK = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Pink.png")
    static let COLOR_PURPLE = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Purple.png")
    static let COLOR_RED = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Red.png")
    static let COLOR_WHITE = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("White.png")
    static let COLOR_YELLOW = CONSTANTS_ENUM.ENUM_SPRITE_SHAPE_COLOR("Yellow.png")
    
    //Number Path
    static let NUMBER_PATH = CONSTANTS_ENUM.ENUM_SPRITE_FOLDER("Asserts/Visual/Numbers/Num")
    
    //Numbers
    /*
    static let NUM0 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("0")
    static let NUM1 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("1")
    static let NUM2 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("2")
    static let NUM3 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("3")
    static let NUM4 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("4")
    static let NUM5 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("5")
    static let NUM6 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("6")
    static let NUM7 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("7")
    static let NUM8 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("8")
    static let NUM9 = CONSTANTS_ENUM.ENUM_SPRITE_NUMBER("9")*/
}

extension Array{
    mutating func removeObject<U:Equatable>(object: U)->Bool{
        for (idx, objectToCompare) in self.enumerate(){
            if let objOfTypeU = objectToCompare as? U{
                if object == objOfTypeU{
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}






