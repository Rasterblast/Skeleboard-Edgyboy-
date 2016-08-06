//
//  GameScene.swift
//  Edgyboy
//
//  Created by Sylvia Dolmo on 7/6/16.
//  Copyright (c) 2016 MakeSchool. All rights reserved.
//

import SpriteKit

enum GameSceneState{
    case Ready, Playing, GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var level = 0
  weak var SexySkeleton: SKSpriteNode!
    var sinceTouch: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0
    var scrollSpeed: CGFloat = 10
 weak var scrollLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var allowJump = true
    var gameState: GameSceneState  = .Ready
    var buttonStart: MSButtonNode!
    var rail: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var points = 0
    var contactRail = false
    var isNowJump = false
    var highJump = true
    var contactGround = false
    var levelTimer: CFTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        SexySkeleton = self.childNodeWithName("//Greg") as! SKSpriteNode
        scrollLayer = self.childNodeWithName("scrollLayer")
        buttonStart = self.childNodeWithName("buttonStart") as! MSButtonNode
        rail = self.childNodeWithName("//rail") as! SKSpriteNode
        scoreLabel = self.childNodeWithName("//scoreLabel") as! SKLabelNode
       
        buttonStart.selectedHandler = {
        
            self.gameState = .Playing
            self.buttonStart.hidden = true
        
        }
        
        if gameState == .Playing {
            buttonStart.hidden = true
        }
        

        
        physicsWorld.contactDelegate = self
        scoreLabel.text = String(points)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        if nodeA.name == "rail" || nodeB.name == "rail"{
            
            var rail: SKNode
            
            if nodeA.name == "rail" {
                rail = nodeA
            }
            else {
                rail = nodeB
            }
            
            let skelePosition = SexySkeleton.convertPoint(CGPointMake(0, 0), toNode: self)
            let railPosition = rail.convertPoint(CGPointMake(0, 0), toNode: self)
            
            if skelePosition.y >= railPosition.y{
                contactRail = true
                highJump = false
                allowJump = true
            }
            
            return
        
        }
        
        contactGround = true
        
        if gameState != .Playing { return }
        
        highJump = true
        allowJump = true
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
         contactRail = false
        contactGround = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameState != .Playing { return }
        
        if allowJump {
            
            sinceTouch = 0
            
            allowJump = false
            
            isNowJump = true
            
            SexySkeleton.physicsBody?.applyImpulse(CGVectorMake(0.45, 35))
            
            // todo: jump animation
            
            let jumping = SKAction(named: "Jumping")!
            SexySkeleton.runAction(jumping)
        }
        
    
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        isNowJump = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        if gameState != .Playing {return}
        scrollWorld()
        let velocitY = SexySkeleton.physicsBody?.velocity.dy ?? 0
        
        
        
        // higher jumping
        if isNowJump && velocitY > 0 && highJump {
            SexySkeleton.physicsBody?.applyForce(CGVectorMake(2, 52))
        }

        
        let skelePosition = SexySkeleton.convertPoint(CGPointMake(0, 0), toNode: self)
        if skelePosition.x < -7{
           gameOver()
            
        }
        else if skelePosition.y < -7{
           gameOver()
        }
        
        if skelePosition.x > self.size.width * 0.5 {
            let diff = skelePosition.x - self.size.width * 0.5
            
            SexySkeleton.position.x -= diff
        }
        
        if SexySkeleton.zRotation >= 0.01 || SexySkeleton.zRotation <= -0.01{
            scrollSpeed = 10
        }
        
        if contactRail == true{
            points += 1
            SexySkeleton.zRotation.clamp(CGFloat(40).degreesToRadians(),CGFloat(30).degreesToRadians())
            SexySkeleton.physicsBody?.angularVelocity.clamp(-2,2)
            
            scoreLabel.text = String(points)
        
        }
        
        if contactGround == true{
            SexySkeleton.zRotation.clamp(CGFloat(10).degreesToRadians(),CGFloat(-10).degreesToRadians())
            SexySkeleton.physicsBody?.angularVelocity.clamp(-2,2)
        }
        
        if SexySkeleton.zRotation >= 1 || SexySkeleton.zRotation <= -1{
            if SexySkeleton.actionForKey("flip") == nil {
                let standingFlip = SKAction(named: "StandingFlip")!
                SexySkeleton.runAction(standingFlip, withKey: "flip")
                
                points += 4
                
                scoreLabel.text = String(points)
            }
            
        }
        
    
        levelTimer += fixedDelta
        
        if levelTimer>10 && self.level + 1 < Levels.count {
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed:Levels[self.level + 1]) as GameScene!
            scene.level = self.level + 1
            scene.gameState = .Playing
            
            scene.scaleMode = .AspectFill
            
            
            skView.presentScene(scene, transition: SKTransition.moveInWithDirection(.Right, duration: 1))
        }
        
        scrollSpeed += 0.02
        
        spawnTimer+=fixedDelta
        updateRails()
        sinceTouch+=fixedDelta
    }
    func scrollWorld(){
        for ground in scrollLayer.children as! [SKSpriteNode]
        {
            ground.position.x -= scrollSpeed
            let groundPosition = ground.convertPoint(CGPoint(x: 0, y: 0), toNode: self)
            if groundPosition.x <= -ground.size.width / 2
            {
                ground.position.x += self.size.width*2
            }
            
        }
        
        
    }
    func updateRails(){
    
        let railPosition = rail.convertPoint(CGPoint(x: 0, y: 0), toNode: self)
        if railPosition.x > self.size.width + rail.size.width {
            
            rail.position = CGPointMake(CGFloat.random(min:-50, max:90), CGFloat.random(min:-50, max:90))

        }
    
    }
    func gameOver(){
        gameState = .GameOver
  
        buttonStart.selectedHandler = {
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            let scene = GameScene(fileNamed:Levels[self.level]) as GameScene!
            scene.level = self.level
            
            scene.scaleMode = .AspectFill
            
            
            skView.presentScene(scene)
        }
        
        buttonStart.hidden = false
   }
    
    
    
}