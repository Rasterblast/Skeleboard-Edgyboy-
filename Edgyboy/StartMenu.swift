//
//  StartMenu.swift
//  Edgyboy
//
//  Created by Sylvia Dolmo on 7/29/16.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import Foundation
import SpriteKit

class StartMenu: SKScene{

    var buttonPlay: MSButtonNode!

    override func didMoveToView(view: SKView) {
        buttonPlay = self.childNodeWithName("buttonPlay") as! MSButtonNode
        
        buttonPlay.selectedHandler = {
            
            if let scene = GameScene(fileNamed:Levels[0]) {
                scene.level = 0
                
                // Configure the view.
                let skView = view
                skView.showsFPS = true
                skView.showsNodeCount = true
                
                /* Sprite Kit applies additional optimizations to improve rendering performance */
                skView.ignoresSiblingOrder = false
                
                
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .AspectFill
                
                skView.presentScene(scene)
            }
            
        }
        
    }


}
