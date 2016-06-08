import Foundation
import CoreMotion

class MainScene: CCNode, CCPhysicsCollisionDelegate{
    //MARK: -variables
    let ANGLE_THRESHOLD:Double = 5.0
    let IMPULSE_SCALER : CGFloat = 9000
    let JUMP_SCALER : CGFloat = 400
    let MAX_VELOCITY : Float = 1000
    
    let motionManager = CMMotionManager()
    var previousDirection = TILT_DIRECTION.CENTER(0)
    
    var _physicsNode: CCPhysicsNode!
    var _groundNode: CCNode!
    var _singleGameModel: GameModelSingle!
    var _criteriaLabel : CCLabelTTF!
    var _engineFire : CCNode!
    var _scoreLabel: CCLabelTTF!
    var _pauseButton : CCButton!
    var _menuNode: CCNode!
    
    var _player1 : Player1Class!
    
    var _background1Sprite : CCSprite!
    var _background2Sprite : CCSprite!
    var backgroundSize = CGSizeZero
    
    
    //MARK: -life Cycle
    func didLoadFromCCB(){
        setup()
    }
    
    override func onEnter() {
        super.onEnter()
        self.userInteractionEnabled = true
        _physicsNode.collisionDelegate = self
        _groundNode.zOrder = 100
        
        _singleGameModel = GameModelSingle.init(physicsNode: _physicsNode, player1: _player1, criteriaLabel: _criteriaLabel,  engineFire: _engineFire, scoreLabel : _scoreLabel)
        _pauseButton.visible = false
        backgroundSize = _background1Sprite.convertContentSizeToPoints(_background1Sprite.contentSize, type: _background1Sprite.contentSizeType)
        
        _singleGameModel.createAdmobBannerAds()
        _singleGameModel.authenticateLocalPlayer()
    
        OALSimpleAudio.sharedInstance().preloadBg("Asserts/Audio/PorUnaCabeza.wav")

    }
    
    override func update(delta: CCTime) {
        loopBackground(delta)
        
        if let currentAttitude  = motionManager.deviceMotion?.attitude{
            let direction = getDeviceTiltDirection(currentAttitude)
            let angleScale = CGFloat(direction.getTiltAngle() / 180.0)
            if direction.toString() != previousDirection.toString(){
                if direction.toString() == TILT_DIRECTION.LEFT(0).toString(){
                    _player1.animationManager.runAnimationsForSequenceNamed("TurnLeft")
                }
                else if direction.toString() == TILT_DIRECTION.RIGHT(0).toString(){
                    _player1.animationManager.runAnimationsForSequenceNamed("TurnRight")
                }
                else
                {
                    _player1.animationManager.runAnimationsForSequenceNamed("StandStill")
                }
                previousDirection = direction
            }
            
            if direction.toString() == TILT_DIRECTION.LEFT(0).toString(){
                if _player1.physicsBody.velocity.x > 5{
                    _player1.physicsBody.applyImpulse(CGPointMake((IMPULSE_SCALER * angleScale * CGFloat(delta) * 5), 0))
                }
                else
                {
                    _player1.physicsBody.applyImpulse(CGPointMake((IMPULSE_SCALER * angleScale * CGFloat(delta)), 0))
                }
            }
            else if direction.toString() == TILT_DIRECTION.RIGHT(0).toString(){
                if _player1.physicsBody.velocity.x < -5{
                    _player1.physicsBody.applyImpulse(CGPointMake(IMPULSE_SCALER * angleScale * CGFloat(delta) * 5, 0))
                }
                else
                {
                    _player1.physicsBody.applyImpulse(CGPointMake(IMPULSE_SCALER * angleScale * CGFloat(delta), 0))
                }
            }
            else{
                if _player1.physicsBody.velocity.x > 5{
                    _player1.physicsBody.applyImpulse(CGPointMake((IMPULSE_SCALER * angleScale * CGFloat(delta) * 5), 0))
                }
                else if _player1.physicsBody.velocity.x < -5{
                    _player1.physicsBody.applyImpulse(CGPointMake(IMPULSE_SCALER * angleScale * CGFloat(delta) * 5, 0))
                }
            }
            
            let xVelocity = clampf(Float(_player1.physicsBody.velocity.x), -(MAX_VELOCITY), MAX_VELOCITY)
            let yVelocity = clampf(Float(_player1.physicsBody.velocity.y), -(MAX_VELOCITY), MAX_VELOCITY)
            _player1.physicsBody.velocity = CGPointMake(CGFloat(xVelocity), CGFloat(yVelocity))
            
            
            var playerPosition = _player1.convertPositionToPoints(_player1.position, type: _player1.positionType)
            let contentSize = _physicsNode.convertContentSizeToPoints(_physicsNode.contentSize, type: _physicsNode.contentSizeType)
            //let playerSize = _player1._playerObject.convertContentSizeToPoints(_player1._playerObject.contentSize, type: _player1._playerObject.contentSizeType)
            playerPosition = ccpClamp(playerPosition, CGPointZero, CGPointMake(contentSize.width , contentSize.height))
            _player1.position = _player1.convertPositionFromPoints(playerPosition, type: _player1.positionType)
            
            for fallingObjectType in _singleGameModel._fallingObjectArray{
                if let fallingObject = fallingObjectType as? CCSprite{
                    var fallingObjectPosition = fallingObject.convertPositionToPoints(fallingObject.position, type: fallingObject.positionType)
                    fallingObjectPosition = ccpClamp(fallingObjectPosition, CGPointZero, CGPointMake(contentSize.width, contentSize.height))
                    fallingObject.position = fallingObject.convertPositionFromPoints(fallingObjectPosition, type: fallingObject.positionType)
                    
                }
            }
        }
    }
    
    //MARK: -touch event
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if _player1.canJump{
            _player1.canJump = false
            _singleGameModel.playSoundEffect(SOUND_EFFECT.SOUND_JUMPING)
            _player1.physicsBody.applyImpulse(CGPointMake(0, JUMP_SCALER))
        }
        
    }
    
    func pauseButtonPressed(){
        _singleGameModel.pauseGame()
        _pauseButton.visible = false
        _menuNode.visible = true
    }
    
    func startButtonPressed(){
        _singleGameModel.startGame()
        _pauseButton.visible = true
        _menuNode.visible = false
    }
    
    func rankButtonPressed(){
        _singleGameModel.showLeaderBoard()
    }
    
    func storeButtonPressed(){
        let storeScene = CCBReader.loadAsScene("IAPScene")
        CCDirector.sharedDirector().replaceScene(storeScene)
    }
    
    //MARK: -collision Delegate
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, droppingObjectType: CCNode!, playerType: CCNode!) -> Bool {
        //print("[Collision] player - droppingObjectType")
        guard droppingObjectType != nil && playerType != nil else{
            return false
        }
        droppingObjectType.physicsBody.collisionType = "Remove"
        droppingObjectType.physicsBody.sensor = true
        if let asFallingObjectProtocol = droppingObjectType as? FallingObjectProtocol{
            _singleGameModel._fallingObjectArray.removeObject(droppingObjectType)
            //print("[RemoveResult]: \(removeResult)")
            
            if  !_singleGameModel.playerCollisionTest(asFallingObjectProtocol.objectAttributes){
                _pauseButton.visible = false
                _menuNode.visible = true
                
                let particle = CCBReader.load("Sprites/CollideParticles2") as! CCParticleSystem
                particle.autoRemoveOnFinish = true
                particle.position = droppingObjectType.position
                droppingObjectType.parent?.addChild(particle)
            }
            else{
                let particle = CCBReader.load("Sprites/CollideParticles1") as! CCParticleSystem
                particle.autoRemoveOnFinish = true
                particle.position = droppingObjectType.position
                droppingObjectType.parent?.addChild(particle)
            }
        }
        
        
        let fadeAction = CCActionFadeOut.init(duration: 0.2)
        let removeAction = CCActionCallBlock { () -> Void in
            droppingObjectType.removeFromParentAndCleanup(true)
        }
        let actionSequence = CCActionSequence.actionWithArray([fadeAction, removeAction]) as! CCActionSequence
        droppingObjectType.runAction(actionSequence)
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, droppingObjectType: CCNode!, ground: CCNode!) -> Bool {
        guard droppingObjectType != nil && ground != nil else{
            return false
        }
        _singleGameModel._fallingObjectArray.removeObject(droppingObjectType)
        //print("[RemoveResult]: \(removeResult) [Count]: \(_singleGameModel._fallingObjectArray.count)")
        
        droppingObjectType.physicsBody.collisionType = "Remove"
        
        let fadeAction = CCActionFadeOut.init(duration: 0.2)
        let removeAction = CCActionCallBlock { () -> Void in
            droppingObjectType.removeFromParentAndCleanup(true)
        }
        let actionSequence = CCActionSequence.actionWithArray([fadeAction, removeAction]) as! CCActionSequence
        droppingObjectType.runAction(actionSequence)
        
        _singleGameModel.playSoundEffect(SOUND_EFFECT.SOUND_BLOP)
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, playerType: CCNode!, ground: CCNode!) -> Bool {
        guard playerType != nil && ground != nil else{
            return true
        }
        _player1.canJump = true
        return true
    }
    
    //MARK: -private functions
    private func setup(){
        //playBackgroundMusic()
        initMotionUpdate()
    }
    
    private func initMotionUpdate(){
        motionManager.deviceMotionUpdateInterval = CCDirector.sharedDirector().animationInterval
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical)
    }
    
    /*
    private func playBackgroundMusic(){
        OALSimpleAudio.sharedInstance().playBg("Asserts/Audio/PorUnaCabeza.wav", loop: true)
        
    }*/
    
    private func getDeviceTiltDirection(currentAttitude: CMAttitude)->TILT_DIRECTION{
        let roll = currentAttitude.roll * 180 / M_PI
        
        var direction : TILT_DIRECTION = TILT_DIRECTION.CENTER(0)
        
        if roll > ANGLE_THRESHOLD{
            direction = TILT_DIRECTION.RIGHT(roll)
        }
        else if  roll < (-ANGLE_THRESHOLD){
            direction = TILT_DIRECTION.LEFT(roll)
        }
        else
        {
            direction = TILT_DIRECTION.CENTER(roll)
        }
        return direction
    }

    private func loopBackground(delta: CCTime){
        var bk1Position = _background1Sprite.convertPositionToPoints(_background1Sprite.positionInPoints, type: _background1Sprite.positionType)
        var bk2Position = _background2Sprite.convertPositionToPoints(_background2Sprite.positionInPoints, type: _background2Sprite.positionType)
        
        bk1Position = CGPointMake((bk1Position.x - CGFloat(delta) * 10 ), 0)
        bk2Position = CGPointMake((bk2Position.x - CGFloat(delta) * 10 ), 0)
        if bk1Position.x < -backgroundSize.width{
            bk1Position.x = backgroundSize.width
        }
        if bk2Position.x < -backgroundSize.width{
            bk2Position.x = backgroundSize.width
        }
        
        _background1Sprite.position = bk1Position
        _background2Sprite.position = bk2Position
    }
}
