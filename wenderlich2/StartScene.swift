//
//  StartScene.swift
//  wenderlich2
//
//  Created by Hector Otero on 2/13/17.
//  Copyright © 2017 Larsen & McDermott Enterprises, LLC. All rights reserved.
//

import Foundation
import SpriteKit

class StartScene: SKScene{
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.lightGray
        
        let message = "Get Ready To Start a New Game!"
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        
        label.text = message
        
        label.fontSize = 21
        
        label.fontColor = SKColor.black
        
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        
        addChild(label)
        
        run(SKAction.sequence([SKAction.wait(forDuration: 5.0),
            SKAction.run(){
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size:size)
                self.view?.presentScene(scene, transition: reveal)
            }
        ]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
