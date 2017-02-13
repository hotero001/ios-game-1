//
//  GameScene.swift
//  wenderlich2
//
//  Created by Hector Otero on 2/9/17.
//  Copyright © 2017 Larsen & McDermott Enterprises, LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Monster : UInt32 = 0b1
    static let Projectile : UInt32 = 0b10
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrt(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    let enemy = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        backgroundColor = SKColor.lightGray
        
        player.position = CGPoint(x: size.width*0.1, y: size.height*0.5)
        enemy.position = CGPoint(x: size.width*0.9, y: size.height*0.5)
        
        addChild(player)
        addChild(enemy)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: 1.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(leftMonster), SKAction.wait(forDuration: 1.0)])))
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random()*(max-min)+min
    }
    
    func leftMonster() {
        let mmonster = SKSpriteNode(imageNamed: "monster")
        let actualYs = random(min: mmonster.size.height/2, max: size.height - mmonster.size.height/2)
        
        mmonster.position = CGPoint(x: 0, y: actualYs)
        
        addChild(mmonster)
        
        mmonster.physicsBody = SKPhysicsBody(rectangleOf: mmonster.size)
        mmonster.physicsBody?.isDynamic = true
        mmonster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        mmonster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        mmonster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDur = random(min: CGFloat(5.0), max: CGFloat(10.0))
        
        let actionsMove = SKAction.move(to: CGPoint(x: mmonster.size.width/2+400, y: actualYs), duration: TimeInterval(actualDur))
        
        let actionsMoveDone = SKAction.removeFromParent()
        
        mmonster.run(SKAction.sequence([actionsMove, actionsMoveDone]))
    }
    
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "monster")
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(10.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y:actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    //override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //}
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    //this action takes place when the player releases their finger from the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else
        {
            return
        }
        let touchLocation = touch.location(in: self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = touchLocation - projectile.position
        
        //by commenting out the line below, the creature can now shoot in the backwards direction
        //if (offset.x < 0) {return}
        
        addChild(projectile)
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.move(to: realDest, duration: 5.0)
        let actionMoveDone = SKAction.removeFromParent()
        
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    //is this supposed to be inside of the touchesEnded method?
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print(arc4random_uniform(20))
        projectile.removeFromParent()
        monster.removeFromParent()
        if player.position == CGPoint(x: size.width*0.1, y: size.height*0.5) {
            player.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
        }else{
            player.position = CGPoint(x: size.width*0.3, y: size.height*0.7)
        }
        
        monstersDestroyed += 1
        if (monstersDestroyed > 3) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    //does this belong inside of the touchesEnded method as well?
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
}



