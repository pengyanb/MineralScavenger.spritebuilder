//
//  Player1Class.swift
//  MatchOnDemand
//
//  Created by Yanbing Peng on 15/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

class Player1Class: CCSprite{
    var _topObject: CCSprite!
    var _topNum: CCSprite!
    var _playerObject: CCSprite!
    
    var objectShape : String = "Circle"
    var objectColor : String = CONSTANTS.COLOR_RED.getAssociatedString()
    var number : Int = 1
    
    var player1FacingDirection = TILT_DIRECTION.CENTER
    
    var objectAttributes = [String:String]()
    
    var canJump = true
    
    //MARK: -set Player attributes
    func setObjectNumber(newNumber:Int){
        number = newNumber
        objectAttributes = ["ObjectShape":objectShape, "ObjectColor":objectColor, "ObjectNumber":"\(number)"]
        _topNum.spriteFrame = CCSpriteFrame.init(imageNamed: (CONSTANTS.NUMBER_PATH.getAssociatedString() + "\(newNumber).png"))
    }
    
    func setObjectShapeAndColor(newShape:String, newColor:String){
        objectShape = newShape
        objectColor = newColor
        objectAttributes = ["ObjectShape":objectShape, "ObjectColor":objectColor, "ObjectNumber":"\(number)"]
        _topObject.spriteFrame = CCSpriteFrame.init(imageNamed: CONSTANTS.PATH_SHAPES.getAssociatedString() + newShape  + newColor)
    }
    
    //MARK: -animation callbacks
    /*
    func player1TurnLeftAnimationComplete(){
        //print("[player1TurnLeftAnimationComplete] 2")
        if player1FacingDirection == TILT_DIRECTION.LEFT{
            self.animationManager.runAnimationsForSequenceNamed("RunLeft")
        }
    }
    
    func player1TurnRightAnimationComplete(){
        //print("[player1TurnLeftAnimationComplete] 2")
        if player1FacingDirection == TILT_DIRECTION.RIGHT{
            self.animationManager.runAnimationsForSequenceNamed("RunRight")
        }
    }*/
}