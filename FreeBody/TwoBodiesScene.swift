//
//  TwoBodiesScene.swift
//  FreeBody
//
//  Created by Jackson Kearl on 12/30/14.
//  Copyright (c) 2014 Applications of Computer Science Club. All rights reserved.
//

import SpriteKit

class TwoBodiesScene: SKScene {
    var isOptionVisible = false
    var isRunning = false
    var basePositionA:CGPoint?
    var basePositionB:CGPoint?
    
    func triangleInRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> SKShapeNode {
        let rect = CGRectMake(x, y, width, height)
        let offsetX: CGFloat = CGRectGetMidX(rect)
        let offsetY: CGFloat = CGRectGetMidY(rect)
        var bezierPath: UIBezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(offsetX, 0))
        bezierPath.addLineToPoint(CGPointMake(-offsetX, offsetY))
        bezierPath.addLineToPoint(CGPointMake(-offsetX, -offsetY))
        bezierPath.closePath()
        
        let shape: SKShapeNode = SKShapeNode()
        shape.path = bezierPath.CGPath
        
        return shape
    }
    
    override init(size: CGSize) {
        super.init(size: size)

        self.backgroundColor = FBColors.BlueDark
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        let backButton = FBButtonNode(text: "Main Menu", identifier: "Back", size: 24)
        backButton.name = "MainMenu"
        self.addChild(backButton)
        backButton.position = CGPointMake(backButton.size.width/2+backButton.size.height/2, backButton.size.height)

        let nodeA = SKShapeNode(circleOfRadius: self.size.width/8)
        nodeA.fillColor = FBColors.Yellow
        nodeA.name = "NodeA"
        nodeA.position = CGPointMake(self.size.width/2, self.size.height/3)
        nodeA.lineWidth = 0
        addChild(nodeA)

        let nodeB = nodeA.copy() as SKShapeNode
        nodeB.name = "NodeB"
        nodeB.position.y = self.size.height*2/3
        addChild(nodeB)
        
        basePositionA = nodeA.position
        basePositionB = nodeB.position

        let startButton = triangleInRect(0, y: 0, width: 32, height: 32)
        startButton.strokeColor = FBColors.YellowBright
        startButton.fillColor = FBColors.YellowBright
        startButton.name = "Play"
        addChild(startButton)
        startButton.position = CGPointMake(startButton.frame.size.width/2+startButton.frame.size.height/2, self.size.height-startButton.frame.size.height)
        
        let stopButton = SKShapeNode(rectOfSize: CGSizeMake(32, 32))
        stopButton.strokeColor = FBColors.YellowBright
        stopButton.fillColor = FBColors.YellowBright
        stopButton.name = "Pause"
        addChild(stopButton)
        stopButton.position = CGPointMake(stopButton.frame.size.width/2+stopButton.frame.size.height/2, self.size.height-stopButton.frame.size.height)
        stopButton.hidden = true
        

        let options = SKShapeNode(rectOfSize: CGSizeMake(self.size.width/3, self.size.height))
        options.fillColor = FBColors.Brown
        options.position = CGPointMake(self.size.width*7/6, self.size.height/2)
        options.name = "Options"
        options.lineWidth = 0
        self.addChild(options)

        self.name = "Background"
        
    }

    func switchPlayButton() {
        isRunning = !isRunning
        
        let startButton = self.childNodeWithName("Play")
        let stopButton = self.childNodeWithName("Pause")
        
        if isRunning {
            // if physics is changed to running, start physics
            for node in self.children {
                (node as SKNode).physicsBody?.dynamic = true
            }
            startButton!.hidden = true
            startButton?.zPosition--
            stopButton!.hidden = false
            stopButton?.zPosition++
        }
        else {
            // Physics is changed to not running, turn it off! Move node to center
            for node in self.children {
                (node as SKNode).physicsBody?.dynamic = isRunning
                if (node as SKNode).name=="NodeA"{
                    println("moving node A back to center")
                    (node as SKNode).position = basePositionA!
                } else if (node as SKNode).name=="NodeB"{
                    println("moving node A back to center")
                    (node as SKNode).position = basePositionB!
                }
            }
            stopButton!.hidden = true
            stopButton?.zPosition--
            startButton!.hidden = false
            startButton?.zPosition++
            
        }
    }

    func showOptionPane() {
        if !isOptionVisible {
            for child in children {
                let name  = (child as SKNode).name
                let pName = (child as SKNode).parent?.name
                if (name == "NodeA" || pName == "NodeA" || name == "NodeB" || pName == "NodeB") {
                    // move central node and children (force arrows in future maybe) to be in new center
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(-self.frame.width/6, 0), duration: 0.25))
                } else if (name == "MainMenu" ) {
                    //stay in the same place
                }
                else {
                    //move all the way. acts on option pane and children, along with all other nodes
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(-self.frame.width/3, 0), duration: 0.25))
                    
                }
            }
            isOptionVisible = true
        }
    }
    
    func hideOptionPane() {
        if isOptionVisible {
            for child in children {
                let name  = (child as SKNode).name
                let pName = (child as SKNode).parent?.name
                if (name == "NodeA" || pName == "NodeA" || name == "NodeB" || pName == "NodeB") {

                    // move central node and children (force arrows in future maybe) to be in new center
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(+self.frame.width/6, 0), duration: 0.25))
                } else if (name == "MainMenu" ) {
                    //stay in the same place
                }
                else {
                    //move all the way. acts on option pane and children, along with all other nodes
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(+self.frame.width/3, 0), duration: 0.25))
                    
                }
            }
            isOptionVisible = false
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let nodeTouched = nodeAtPoint(touch.locationInNode(self))
        if (nodeTouched.parent?.parent is FBButtonNode) {
            (nodeTouched.parent!.parent as FBButtonNode).setTouched(true)
        }
    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch

        let nodeTouched = nodeAtPoint(touch.previousLocationInNode(self))

        if (nodeTouched !== nodeAtPoint(touch.locationInNode(self))) {
            if (nodeTouched.parent?.parent is FBButtonNode) {
                (nodeTouched.parent!.parent as FBButtonNode).setTouched(false)
            }
        }
    }
    

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let nodeTouched = nodeAtPoint(touch.locationInNode(self))

        if (nodeTouched.parent?.parent is FBButtonNode) {
            (nodeTouched.parent!.parent as FBButtonNode).setTouched(false)
        }
        
        if (nodeTouched.name? != nil) {
            switch nodeTouched.name! {
            case "NodeA", "NodeB":
                showOptionPane()
                
            case "Options":
                print()
                
            case "Background":
                hideOptionPane()
                
            case "Play":
                switchPlayButton()
                
            case "Pause":
                switchPlayButton()
                
            case "Back":
                self.view!.presentScene(MainMenuScene(size: self.size), transition: .doorsCloseHorizontalWithDuration(0.5))
                
            default:
                println("Nothing Touched")
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
}
