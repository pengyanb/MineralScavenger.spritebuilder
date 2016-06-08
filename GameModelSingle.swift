//
//  GameModelSingle.swift
//  MatchOnDemand
//
//  Created by Yanbing Peng on 10/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
import GameKit
import GoogleMobileAds

class GameModelSingle :  CCNode, GKGameCenterControllerDelegate, GADInterstitialDelegate {
    private let objectShapeSpriteFileArray = [CONSTANTS.SPRITE_FILE_NAME_CIRCLE, CONSTANTS.SPRITE_FILE_NAME_HEART, CONSTANTS.SPRITE_FILE_NAME_STAR, CONSTANTS.SPRITE_FILE_NAME_OVAL, CONSTANTS.SPRITE_FILE_NAME_PENTAGON, CONSTANTS.SPRITE_FILE_NAME_RECTANGLE, CONSTANTS.SPRITE_FILE_NAME_SQUARE,  CONSTANTS.SPRITE_FILE_NAME_TRIANGLE]
    
    private let objectShapeFolderArray = [CONSTANTS.SPRITE_CIRCLE_FOLDER, CONSTANTS.SPRITE_HEART_FOLDER, CONSTANTS.SPRITE_STAR_FOLDER, CONSTANTS.SPRITE_OVAL_FOLDER, CONSTANTS.SPRITE_PENTAGON_FOLDER, CONSTANTS.SPRITE_RECTANGLE_FOLDER, CONSTANTS.SPRITE_SQUARE_FOLDER, CONSTANTS.SPRITE_TRIANGLE_FOLDER]
    
    private let objectColorArray = [CONSTANTS.COLOR_BLUE, CONSTANTS.COLOR_CYAN, CONSTANTS.COLOR_GREEN, CONSTANTS.COLOR_ORANGE, CONSTANTS.COLOR_PINK, CONSTANTS.COLOR_PURPLE, CONSTANTS.COLOR_RED, CONSTANTS.COLOR_WHITE, CONSTANTS.COLOR_YELLOW]
    
    //MARK: -variables
    var _fallingObjectArray = [FallingObjectProtocol]()
    
    private let _physicsNode : CCPhysicsNode!
    private let _player1 : Player1Class!
    private let _criteriaLabel:CCLabelTTF!
    private let _engineFire:CCNode!
    private let _scoreLabel:CCLabelTTF!
    
    private var spawnInterval : Double = 2.0
    
    private var isRunning = false
    
    private var spawnTimer:CCTimer!
    
    private var maxShape = 3
    private var maxColor = 3
    private var maxNumber = 3
    
    private var attributeSelector = 0
    
    private var bannerView:GADBannerView!
    
    private var interstitialView : GADInterstitial!
    
    private var canShowInterstitialAd = false
    
    private var gameScore:Int = 0{
        didSet{
            if gameScore > 0{
                playSoundEffect(SOUND_EFFECT.SOUND_LEVEL_UP1)
                
                var scoreRemainder = gameScore % 5  //every 5 level
                if scoreRemainder == 0{
                    if spawnInterval > 1{
                        spawnInterval = spawnInterval * 0.8
                        setupSpawnTimer(spawnInterval)
                    }
                }
                
                scoreRemainder = gameScore % 10
                if scoreRemainder == 0 //every 10 level
                {
                    attributeSelector += 1
                    let attriRemainder = attributeSelector % 3
                    
                    if attriRemainder == 0{
                        if maxNumber < 10{
                            maxNumber+=1
                        }
                    }
                    else if attriRemainder == 1{
                        if maxShape < objectShapeFolderArray.count{
                            maxShape+=1
                        }
                    }
                    else if attriRemainder == 2{
                        if maxColor < objectColorArray.count{
                            maxColor+=1
                        }
                    }
                }
            }
            _scoreLabel.string = "\(gameScore)"
        }
    }
    
    private var currentMatchCriteria = MATCHING_CRITERIA.SHAPE{
        didSet{
            _criteriaLabel.string = currentMatchCriteria.toString()
        }
    }
    
    private var userDefault : [String:AnyObject]?
    
    private var physicsNodeContentSize = CGSizeZero
    
    private var fallingObjectSize = CGSizeZero
    
    private var maxFallingObjectCount = 1
    
    //MARK: -init
    init(physicsNode: CCPhysicsNode, player1 : Player1Class, criteriaLabel : CCLabelTTF, engineFire:CCNode, scoreLabel: CCLabelTTF){
        _physicsNode = physicsNode
        _player1 = player1
        _criteriaLabel = criteriaLabel
        _engineFire = engineFire
        _scoreLabel = scoreLabel
    
        
        let objectNumber = Int(arc4random_uniform(UInt32(maxNumber)))
        _player1.setObjectNumber(objectNumber)
        let objectShape = objectShapeFolderArray[Int(arc4random_uniform(UInt32(maxShape)))]
        let objectColor = objectColorArray[Int(arc4random_uniform(UInt32(maxColor)))]
        _player1.setObjectShapeAndColor(objectShape.getAssociatedString(), newColor: objectColor.getAssociatedString())
        
        if let _userDefaults = NSUserDefaults.standardUserDefaults().objectForKey(CONSTANTS.NSUSER_DEFAULT_KEY) as? [String:AnyObject]{
            userDefault = _userDefaults
        }
        
        physicsNodeContentSize = _physicsNode.convertContentSizeToPoints(_physicsNode.contentSize, type: _physicsNode.contentSizeType)

        let fallingObjectShape = objectShapeSpriteFileArray[Int(arc4random_uniform(UInt32(maxShape)))]
        let fallingObject = CCBReader.load(fallingObjectShape.getAssociatedString())
        fallingObjectSize = fallingObject.convertContentSizeToPoints(fallingObject.contentSize, type: fallingObject.contentSizeType)
        
        let remainder  = physicsNodeContentSize.width / fallingObjectSize.width
        maxFallingObjectCount = Int((physicsNodeContentSize.width - remainder) / fallingObjectSize.width)
        print("[MaxFallingObjectCount]: \(maxFallingObjectCount)")
    }
    
    //MARK: -API func
    func startGame()
    {
        _fallingObjectArray = [FallingObjectProtocol]()
        _criteriaLabel.visible = true
        _engineFire.visible = true
        OALSimpleAudio.sharedInstance().playBg("Asserts/Audio/PorUnaCabeza.wav", loop: true)
        if bannerView != nil{
            bannerView.center = CGPoint(x: bannerView.center.x, y: bannerView.center.y + bannerView.frame.size.height)
        }
        if isRunning{
            CCDirector.sharedDirector().resume()
        }
        else{
            canShowInterstitialAd = false
            createAdMobInterstitialAds()
            
            isRunning = true
            maxShape = 3
            maxColor = 3
            maxNumber = 3
            spawnInterval = 2.0
            setupSpawnTimer(spawnInterval)
            _criteriaLabel.visible = true
            generateNewCriteria()
            gameScore = 0
        }
        
    }
    func pauseGame(){
        _criteriaLabel.visible = false
        _engineFire.visible = false
        if bannerView != nil{
            bannerView.center = CGPoint(x: bannerView.center.x, y: bannerView.center.y - bannerView.frame.size.height)
        }
        OALSimpleAudio.sharedInstance().stopBg()
        CCDirector.sharedDirector().pause()
    }
    func stopGame(){
        for fallingObject in _fallingObjectArray{
            if let fallingNode = fallingObject as? CCNode{
                _physicsNode.removeChild(fallingNode)
            }
        }
        
        _fallingObjectArray.removeAll()
        
        isRunning = false
        _criteriaLabel.visible = false
        _engineFire.visible = false
        OALSimpleAudio.sharedInstance().stopBg()
        if spawnTimer != nil{
            spawnTimer.invalidate()
            playSoundEffect(SOUND_EFFECT.SOUND_SHATTERING)
        }
        saveHighScore(gameScore)
        
        if bannerView != nil{
            bannerView.center = CGPoint(x: bannerView.center.x, y: bannerView.center.y - bannerView.frame.size.height)
        }
        
        self.scheduleBlock({ [unowned self](_) in
            print("[ShowInterstitialAction]")
            if self.interstitialView != nil && self.canShowInterstitialAd{
                self.canShowInterstitialAd = false
                self.interstitialView.presentFromRootViewController(UIApplication.sharedApplication().keyWindow?.rootViewController)
            }
        }, delay: 2.0)
    }
    
    //MARK: -Private func
    private func setupSpawnTimer(interval:Double){
        if spawnTimer != nil{
            spawnTimer.invalidate()
        }
        spawnTimer = self.schedule(#selector(spawnFallingObject), interval: CCTime.init(interval))
    }
    
    func playerCollisionTest(objectInfo:[String:String])->Bool{
        var keepGoing = false
        switch currentMatchCriteria{
        case .SHAPE:
            if objectInfo["ObjectShape"] == _player1.objectAttributes["ObjectShape"]{
                _player1.setObjectNumber(Int(objectInfo["ObjectNumber"]!)!)
                _player1.setObjectShapeAndColor(objectInfo["ObjectShape"]!, newColor: objectInfo["ObjectColor"]!)
                generateNewCriteria()
                gameScore+=1
                keepGoing = true
            }
        case .COLOR:
            if objectInfo["ObjectColor"] == _player1.objectAttributes["ObjectColor"]{
                _player1.setObjectNumber(Int(objectInfo["ObjectNumber"]!)!)
                _player1.setObjectShapeAndColor(objectInfo["ObjectShape"]!, newColor: objectInfo["ObjectColor"]!)
                generateNewCriteria()
                gameScore+=1
                keepGoing = true
            }
        case .NUMBER:
            if objectInfo["ObjectNumber"] == _player1.objectAttributes["ObjectNumber"]{
                _player1.setObjectNumber(Int(objectInfo["ObjectNumber"]!)!)
                _player1.setObjectShapeAndColor(objectInfo["ObjectShape"]!, newColor: objectInfo["ObjectColor"]!)
                generateNewCriteria()
                gameScore+=1
                keepGoing = true
            }
        }
        if !keepGoing{
            stopGame()
        }

        return keepGoing
    }
    
    func playSoundEffect(soundName: SOUND_EFFECT){
        OALSimpleAudio.sharedInstance().playEffect("Asserts/Audio/"+soundName.toString())
    }
    
    func generateNewCriteria(){
        if let criteria =  MATCHING_CRITERIA(rawValue: Int(arc4random_uniform(UInt32(3)))){
            currentMatchCriteria = criteria
        }
    }
    
    func spawnFallingObject(){
        if isRunning{

            let randomX = CGFloat(Int(arc4random_uniform(UInt32(physicsNodeContentSize.width) - UInt32(fallingObjectSize.width / 2.0))) + Int(fallingObjectSize.width / 2.0)) / 2.0
            var fallingSpritePosition = CGPointMake(randomX, physicsNodeContentSize.height)
            
            for _ in 0 ..< maxFallingObjectCount {
                if fallingSpritePosition.x < (physicsNodeContentSize.width - fallingObjectSize.width / 2.0){
                    let createdOrNot = Int(arc4random_uniform(2))
                    if createdOrNot == 1{
                        let objectShape = objectShapeSpriteFileArray[Int(arc4random_uniform(UInt32(maxShape)))]
                        if let fallingObject = CCBReader.load(objectShape.getAssociatedString()) as? FallingObjectProtocol{
                            let objectColor = objectColorArray[Int(arc4random_uniform(UInt32(maxColor)))]
                            fallingObject.setOjectColor(objectColor.getAssociatedString())
                            let objectNumber = Int(arc4random_uniform(UInt32(maxNumber)))
                            fallingObject.setObjectNumber(objectNumber)
                            
                            
                            let fallingSprite = fallingObject as! CCSprite
                            
                            fallingSprite.position = fallingSpritePosition
                            fallingSprite.zOrder = 1
                            fallingSprite.physicsBody.density = (CGFloat(arc4random_uniform(100)) + 1)
                            _physicsNode.addChild(fallingSprite)
                            _fallingObjectArray.append(fallingObject)
                            
                        }
                    }
                    fallingSpritePosition.x = fallingSpritePosition.x + fallingObjectSize.width
                }
                else{
                    break
                }
            }
            
            
        }
    }
    
    //MARK: -AdMob funcs
    func createAdmobBannerAds(){
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController{
            if bannerView == nil{
                bannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
            }
            bannerView.adUnitID = CONSTANTS.ADMOB_BANNER_ADUNITID
            bannerView.center = CGPoint(x: bannerView.center.x, y: rootViewController.view.bounds.size.height - bannerView.frame.size.height / 2)
            bannerView.rootViewController = rootViewController
            rootViewController.view.addSubview(bannerView)
            bannerView.loadRequest(GADRequest.init())
        }
    }
    
    func createAdMobInterstitialAds(){
        if interstitialView == nil{
            interstitialView = GADInterstitial(adUnitID: CONSTANTS.ADMOB_INTERSTitial_ADUNITID)
            interstitialView.delegate = self
        }
        interstitialView.loadRequest(GADRequest())
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        if userDefault != nil{
            if let removeAdsPurchased = userDefault![CONSTANTS.STORE_ITEM_IDENTIFIER1.getAssociatedString()] as? Bool{
                if removeAdsPurchased == true{
                    return
                }
            }
        }
        if isRunning{
            canShowInterstitialAd = true;
        }
        else{
            if interstitialView != nil{
                interstitialView.presentFromRootViewController(UIApplication.sharedApplication().keyWindow?.rootViewController)
            }
        }
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        canShowInterstitialAd = false
        if interstitialView != nil{
            interstitialView.delegate = nil
            interstitialView = nil
        }
    }
    
    //MARK: -GKGameCenter related func and delegate func
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if let vc = viewController {
                //[[CCDirector sharedDirector] presentViewController:vc animated:YES completion:nil];
                CCDirector.sharedDirector().presentViewController(vc, animated: true, completion: nil)
            }
            else{
                if error != nil{
                    print("\(error!)")
                }
                print(GKLocalPlayer.localPlayer().authenticated)
            }
        }
    }
    
    func saveHighScore(score: Int){
        if GKLocalPlayer.localPlayer().authenticated{
            let scoreReporter = GKScore(leaderboardIdentifier: "MineralScavengerLeaderboard")
            scoreReporter.value = Int64(gameScore)
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error ) in
                if error != nil{
                    print("\(error!)")
                }
                else{
                    //self.showLeaderBoard()
                }
            })
        }
    }
    
    func showLeaderBoard(){
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        CCDirector.sharedDirector().presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}






























