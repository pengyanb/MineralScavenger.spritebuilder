//
//  PentagonSprite.swift
//  MatchOnDemand
//
//  Created by Yanbing Peng on 10/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class PentagonSprite : CCSprite, FallingObjectProtocol{
    var numSprite : CCSprite!
    
    let objectShape : String = "Pentagon/"
    var objectColor : String = CONSTANTS.COLOR_RED.getAssociatedString()
    var number : Int = 1
    
    var objectAttributes = [String:String]()
    
    func setOjectColor(newColor:String){
        objectColor = newColor
        objectAttributes = ["ObjectShape":objectShape, "ObjectColor":objectColor, "ObjectNumber":"\(number)"]
        self.spriteFrame = CCSpriteFrame.init(imageNamed: (CONSTANTS.PATH_SHAPES.getAssociatedString() + CONSTANTS.SPRITE_PENTAGON_FOLDER.getAssociatedString() + newColor))
    }
    
    func setObjectNumber(newNumber:Int){
        number = newNumber
        objectAttributes = ["ObjectShape":objectShape, "ObjectColor":objectColor, "ObjectNumber":"\(number)"]
        numSprite.spriteFrame = CCSpriteFrame.init(imageNamed: (CONSTANTS.NUMBER_PATH.getAssociatedString() + "\(newNumber).png"))
    }
}