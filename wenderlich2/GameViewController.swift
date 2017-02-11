//
//  GameViewController.swift
//  wenderlich2
//
//  Created by Hector Otero on 2/9/17.
//  Copyright © 2017 Larsen & McDermott Enterprises, LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
