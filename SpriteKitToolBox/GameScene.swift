//
//  GameScene.swift
//  SpriteKitToolBox
//
//  Created by Jeremy Dowell on 3/9/15.
//  Copyright (c) 2015 Jeremy Dowell. All rights reserved.
//

import SpriteKit


enum BodyTypes:UInt32 {
    case player = 1
    case landscape = 2
}








class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    var player:PlayerNode!
    var markers:SKNode!

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        super.didMoveToView(view)
        
        // create a border body for the scene so that the player can't fall off the screen
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 0
        self.physicsBody = borderBody
        
        // get the height markers node from the scene
        markers = childNodeWithName("markers")
        
        
        
        // get the player node from the scene
        let spawnNode:SKSpriteNode! = childNodeWithName("player") as! SKSpriteNode
        player = PlayerNode(spawnNode: spawnNode)

        addChild(player)
        player.controller.frame = self.frame
        spawnNode.removeFromParent()
        
        
        
        // set the appropriate category bitmasks for the ground and walls
        self.enumerateChildNodesWithName("landscape") {
         node, stop in
            node.physicsBody?.categoryBitMask = BodyTypes.landscape.rawValue
        }

        
        // create height markers for demonstration purposes
        createHeightMarkers()
        
        
        self.physicsWorld.contactDelegate = self
    }
    
    // Game Loop
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //player?.update(currentTime)
        player.update(currentTime)
    }
    
    /** EVENT HANDLERS **/
    
    /** Input Handlers **/
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            player.controller.touchesBegan(location, event: event)
            
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            player.controller.touchesMoved(location, previousLocation: previousLocation, event: event)
            
        }

    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            player.controller.touchesEnded(location, event: event)
        }

    }

    
    /** Physics Handlers **/
    func didBeginContact(contact: SKPhysicsContact) {
        let (firstBody, secondBody) = sortBodies(contact)
        // If the player is a contacting body, it will -always- be the first body
        if(firstBody.categoryBitMask == BodyTypes.player.rawValue) {
            player.beganContactWith(secondBody, contact:contact)
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let (firstBody, secondBody) = sortBodies(contact)
        if(firstBody.categoryBitMask == BodyTypes.player.rawValue) {
            player.endedContactWith(secondBody, contact: contact)
        }

    }
    
    func sortBodies(contact:SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        var firstBody:SKPhysicsBody!
        var secondBody:SKPhysicsBody!
        
        // An SKPhysicsContact object is created when 2 physics bodies make contact,
        // and those bodies are referenced by its bodyA and bodyB properties.
        // We want to sort these bodies by their bitmasks so that it's easier
        // to identify which body belongs to which sprite.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        return (firstBody, secondBody)
        
    }
    
    func createHeightMarkers() {
        // These functions use the canvas context to draw lines using the canvas API
        let totalLines:CGFloat = self.frame.height / 32
        var lineCount:CGFloat = 0.0
        //let lineColor = SKColor(r: 233, g: 162, b: 255, a: 1.0)
        let lineColor = SKColor(fromCSS: "#dfa2ff")
        for(var y:CGFloat = self.frame.height; y > 0; y -= 32) {
            lineCount += 1.0
            var shape = SKShapeNode()
            var path:CGMutablePathRef = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 0.0, CGFloat(y))
            CGPathAddLineToPoint(path, nil, self.frame.width, y)
            shape.path = path
            shape.strokeColor = lineColor
            shape.lineWidth = 2;
            let alpha = 1.0 - (lineCount / totalLines)
            shape.alpha = alpha
            markers.addChild(shape)
        }

    }
}
