//
//  GameScene.swift
//  Flappy
//
//  Created by Henry AT on 9/22/15.
//  Copyright (c) 2015 Apps4s. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  let birdGroup: UInt32 = 0x1 << 0
  let enemyObjectsGroup: UInt32 = 0x1 << 1
  let openingGroup: UInt32 = 0x1 << 2
  
  enum objectZPositions: CGFloat {
    case background = 0
    case ground = 1
    case pipes = 2
    case bird = 3
    case score = 4
    case gameOver = 5
  }
  
  var movingGameObjects = SKNode()
  
  var background = SKSpriteNode()
  var bird = SKSpriteNode()
  
  var pipeSpeed: NSTimeInterval = 7
  var pipesSpawned: Int = 0
  
  var gameOver: Bool = false
  
  var score: Int = 0
  var scoreLabelNode = SKLabelNode()
  
  var gameOverLabelNode = SKLabelNode()
  var gameOverStatusNode = SKLabelNode()
  
  
    override func didMoveToView(view: SKView) {
      // Physics World
      self.physicsWorld.contactDelegate = self
      self.physicsWorld.gravity = CGVectorMake(0, -15)
      
      self.addChild(movingGameObjects)
      
      // Background
      createBackground()
      
      // Add Bird
      let birdTexture1 = SKTexture(imageNamed: "bird1.png")
      let birdTexture2 = SKTexture(imageNamed: "bird2.png")
      let birdTexture3 = SKTexture(imageNamed: "bird3.png")
      let birdTexture4 = SKTexture(imageNamed: "bird4.png")
      let birdTexture5 = SKTexture(imageNamed: "bird5.png")
      let birdTexture6 = SKTexture(imageNamed: "bird6.png")
      let birdTexture7 = SKTexture(imageNamed: "bird7.png")
      let birdTexture8 = SKTexture(imageNamed: "bird8.png")
      
      
      let flyAnimation = SKAction.animateWithTextures([birdTexture1, birdTexture2, birdTexture3, birdTexture4, birdTexture5, birdTexture6, birdTexture7, birdTexture8], timePerFrame: 0.1)
      
      let flyForever = SKAction.repeatActionForever(flyAnimation)
      
      bird = SKSpriteNode(texture: birdTexture1)
      
      bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
      bird.zPosition = objectZPositions.bird.rawValue
      bird.runAction(flyForever, withKey: "birdFly")
      
      
      
      bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
      
      bird.physicsBody?.categoryBitMask = birdGroup
      bird.physicsBody?.contactTestBitMask = openingGroup | enemyObjectsGroup
      bird.physicsBody?.collisionBitMask = enemyObjectsGroup
      
      bird.physicsBody?.allowsRotation = false
      
      self.addChild(bird)
      
      // Add Ground
      
      let ground = SKNode()
      ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 1))
      
      ground.physicsBody?.dynamic = false
      ground.position = CGPoint(x: CGRectGetMidY(self.frame), y: 0)
      ground.zPosition = objectZPositions.ground.rawValue
      ground.physicsBody?.categoryBitMask = enemyObjectsGroup
      ground.physicsBody?.collisionBitMask = birdGroup
      ground.physicsBody?.contactTestBitMask = birdGroup
      
      self.addChild(ground)
      
      // Score Label Node
      scoreLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
      scoreLabelNode.fontSize = 50
      scoreLabelNode.fontColor = SKColor.whiteColor()
      scoreLabelNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 50)
      scoreLabelNode.text = "0"
      scoreLabelNode.zPosition = objectZPositions.score.rawValue
      self.addChild(scoreLabelNode)
      
      NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "loadPipes", userInfo: nil, repeats: true)
      
    }
  
  func loadPipes() {
    
    pipesSpawned += 2
    if pipesSpawned % 10 == 0 {
      pipeSpeed  -= 0.5
    }
    
    let gap: CGFloat = bird.size.height * 3.5
    
    let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
    let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
    
    let pipe1 = SKSpriteNode(texture: pipe1Texture)
    let pipe2 = SKSpriteNode(texture: pipe2Texture)
    
    
    let randomY: CGFloat = CGFloat(arc4random_uniform(UInt32(self.frame.height * 0.7)))
    
    pipe1.position = CGPoint(x: self.frame.width + pipe1.size.width, y: pipe1.size.height/2 + 150 + randomY + gap/2)
    
    pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
    pipe1.physicsBody?.dynamic = false
    pipe1.physicsBody?.categoryBitMask = enemyObjectsGroup
    pipe1.physicsBody?.collisionBitMask = birdGroup
    pipe1.physicsBody?.contactTestBitMask = birdGroup
    
    pipe1.zPosition = objectZPositions.pipes.rawValue
    movingGameObjects.addChild(pipe1)
    
    let movePipe = SKAction.moveToX(-pipe1.size.width, duration: pipeSpeed)
    let removePipe = SKAction.removeFromParent()
    pipe1.runAction(SKAction.sequence([movePipe, removePipe]))
    
    
    pipe2.position = CGPoint(x: self.frame.width + pipe2.size.width, y: -pipe2.size.height/2 + 150 + randomY - gap/2)
    pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
    pipe2.physicsBody?.dynamic = false
    pipe2.physicsBody?.categoryBitMask = enemyObjectsGroup
    pipe2.physicsBody?.collisionBitMask = birdGroup
    pipe2.physicsBody?.contactTestBitMask = birdGroup
    
    pipe2.zPosition = objectZPositions.pipes.rawValue
    movingGameObjects.addChild(pipe2)
    
    pipe2.runAction(SKAction.sequence([movePipe, removePipe]))
    
    let crossing = SKNode()
    crossing.position = CGPoint(x: pipe1.position.x + pipe1.size.width/2, y: CGRectGetMidY(self.frame))
    crossing.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, self.frame.height))
    crossing.physicsBody?.dynamic = false
    crossing.physicsBody?.categoryBitMask = openingGroup
    crossing.physicsBody?.contactTestBitMask = birdGroup
    movingGameObjects.addChild(crossing)
    crossing.runAction(SKAction.sequence([movePipe, removePipe]))
    
    
  }
  
  
  
  
  func createBackground() {
    
    let backgroundTexture = SKTexture(imageNamed: "background")
    
    let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 12)
    let replaceBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
    let backgroundSequence = SKAction.sequence([moveBackground, replaceBackground])
    let moveBackgroundForever = SKAction.repeatActionForever(backgroundSequence)
    
    for var i: CGFloat = 0; i < 2; i++ {
      
      background = SKSpriteNode(texture: backgroundTexture)
      background.position = CGPoint(x: backgroundTexture.size().width/2 + i * backgroundTexture.size().width, y: CGRectGetMidY(self.frame))
      background.size.height = self.frame.height
      background.zPosition = objectZPositions.background.rawValue
      background.runAction(moveBackgroundForever)
      
      movingGameObjects.addChild(background)
      
      
    }
    
  }
  
  
  
  
  
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
      
      if gameOver == false {
        
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 60))
        
        let rotateUp = SKAction.rotateToAngle(0.2, duration: 0)
        bird.runAction(rotateUp)
        
        
      } else {
        
        let scene = GameScene(fileNamed: "GameScene")
        scene!.scaleMode = .AspectFill
        let transition = SKTransition.doorsOpenHorizontalWithDuration(1.0)
        self.view?.presentScene(scene!, transition: transition)
        
        
        
      }
      
      
    }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    
    if gameOver == false {
      
      let rotateDown = SKAction.rotateToAngle(-0.1, duration: 0)
      bird.runAction(rotateDown)
      
    }
    
  }
  
  
  func didBeginContact(contact: SKPhysicsContact) {
    
    if contact.bodyA.categoryBitMask == openingGroup || contact.bodyB.categoryBitMask == openingGroup {
      
      score += 1
      scoreLabelNode.text = "\(score)"
      
      
    } else if contact.bodyA.categoryBitMask == enemyObjectsGroup || contact.bodyB.categoryBitMask == enemyObjectsGroup {
      
      self.physicsWorld.contactDelegate = nil
      
      movingGameObjects.speed = 0
      gameOver = true
      bird.removeActionForKey("birdFly")
      
      gameOverLabelNode = SKLabelNode(fontNamed: "Copperplate-Bold")
      gameOverLabelNode.fontSize = 50
      gameOverLabelNode.fontColor = SKColor.whiteColor()
      gameOverLabelNode.zPosition = objectZPositions.gameOver.rawValue
      gameOverLabelNode.text = "Game Over"
      gameOverLabelNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
      self.addChild(gameOverLabelNode)
      
      let scaleUp = SKAction.scaleTo(1.5, duration: 2)
      let scale = SKAction.scaleTo(1, duration: 0.25)
      let scaleSequence = SKAction.sequence([scaleUp, scale])
      
      gameOverLabelNode.runAction(scaleSequence, completion: { () -> Void in
        
        self.gameOverStatusNode = SKLabelNode(fontNamed: "Copperplate")
        self.gameOverStatusNode.fontSize = 30
        self.gameOverStatusNode.fontColor = SKColor.whiteColor()
        self.gameOverStatusNode.zPosition = objectZPositions.gameOver.rawValue
        self.gameOverStatusNode.text = "Tap to restart"
        self.gameOverStatusNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - self.gameOverStatusNode.frame.height - 20)
        self.addChild(self.gameOverStatusNode)
        
        let fadeOut = SKAction.fadeAlphaBy(0, duration: 0.5)
        let fadeIn = SKAction.fadeAlphaBy(1, duration: 0.5)
        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
        let fadeForEver = SKAction.repeatActionForever(fadeSequence)
        self.gameOverStatusNode.runAction(fadeForEver)
        
        
        
      })
      
      
    }
    
    
    
  }
  
  
  
  
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
