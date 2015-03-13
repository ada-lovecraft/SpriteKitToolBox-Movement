//
//  PlayerNode.swift
//  SpriteKitToolBox
//
//  Created by Jeremy Dowell on 3/11/15.
//  Copyright (c) 2015 Jeremy Dowell. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerNode:SKSpriteNode  {
    let controller:PlayerController!
    var currentTime:CFTimeInterval
    let options:AnyObject!
    let jumpSpeed:CGFloat!
    let maxJumpTime:CGFloat!
    let maxJumps:Int!
    let walkDrag:CGFloat!
    let walkAcceleration:CGFloat!
    let walkMaxSpeed:CGFloat!
    
    var onWall = false
    var onGround = false
    
    convenience init(spawnNode:SKSpriteNode) {
        self.init()
        self.position = spawnNode.position
        self.color = spawnNode.color
    }
    
    init() {
        
        controller = PlayerController()
        
        let settings = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("GameSettings", ofType: "plist")!)
        
        options = settings!.objectForKey("PlayerOptions")!
        
        maxJumpTime = options.valueForKeyPath("jump.hangtime") as! CGFloat
        maxJumps = options.valueForKeyPath("jump.maxJumps") as! Int
        
        jumpSpeed = options.valueForKeyPath("jump.speed") as! CGFloat
        
        walkDrag = options.valueForKeyPath("walk.drag") as! CGFloat
        walkAcceleration = options.valueForKeyPath("walk.acceleration") as! CGFloat
        
        walkMaxSpeed = options.valueForKeyPath("walk.maxSpeed") as! CGFloat
        
        currentTime = 0.0
        controller.jumpsRemaining = options.valueForKeyPath("jump.maxJumps") as! Int
        
        super.init(texture:nil, color: UIColor.whiteColor(), size: CGSizeMake(32,32))
        
        let playerBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(32,32))
        physicsBody = playerBody
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 0.0
        physicsBody?.linearDamping = 0.0
        physicsBody?.angularDamping = 0.0
        physicsBody?.allowsRotation = false
        
        // add the correct category and contact bit masks to the player sprite
        physicsBody!.categoryBitMask = BodyTypes.player.rawValue
        physicsBody!.contactTestBitMask = BodyTypes.landscape.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func jump() {

        var  jumpTime = CGFloat(currentTime - controller.jumpStartTime)
        if(jumpTime <= maxJumpTime) {
            if !onWall {
                physicsBody?.velocity.dy = jumpSpeed
            } else {
                physicsBody?.velocity.dy = jumpSpeed / 4.0
            }
        }
        

        
    }
    
    func walk(direction:MoveDirections) {
        let force:CGVector!
        
        switch(direction) {
        case .Left:
            force = CGVectorMake(-walkAcceleration,0)
            break
        case .Right:
            force = CGVectorMake(walkAcceleration,0)
            break
        default:
            force = CGVector.zeroVector
        }
        
        physicsBody?.linearDamping = 0.0
        physicsBody?.applyForce(force)
        
        
        // clamp the forces to our settings
        if(physicsBody?.velocity.dx < -walkMaxSpeed) {
            physicsBody?.velocity.dx = -walkMaxSpeed
        } else if(physicsBody?.velocity.dx > walkMaxSpeed) {
            physicsBody?.velocity.dx = walkMaxSpeed
        }
    }
    
    func idle() {
        physicsBody?.linearDamping = walkDrag
    }
    
    func moveWith(direction:MoveDirections) {
        
        switch(direction) {
        case .Up:
            jump()
        case .Left:
            fallthrough
        case .Right:
            walk(direction)
        case .None:
            fallthrough
        default:
            idle()
        }
        
    }
        
    
    
    func groundHit() {
        controller.jumpsRemaining = maxJumps
        onGround = true
        //println("contacted ground")
    }
    
    func wallHit() {
        controller.jumpsRemaining += 1
        if(!onGround) {
            onWall = true
            physicsBody?.affectedByGravity = false
            physicsBody?.velocity.dy = 0.0
        }
        
    }
    
    func groundLeave() {
        onGround = false
    }
    
    func wallLeave() {
        physicsBody?.affectedByGravity = true
        onWall = false
        println("wall leave")
    }
    
    func update(currentTime:CFTimeInterval) {
        self.currentTime = currentTime
        
        for direction in controller.movements  {
            moveWith(direction)
        }
        if(onWall) {
            println("on wall")
            let gravity = scene?.physicsWorld.gravity.dy
            physicsBody?.applyForce(CGVectorMake(0.0, CGFloat(gravity! / 2.0)))
        }
    }
    
    
    func beganContactWith(body: SKPhysicsBody, contact:SKPhysicsContact) {
            switch(body.categoryBitMask) {
            case BodyTypes.landscape.rawValue:
                let node = body.node as! SKSpriteNode
                // minY is top edge
                // maxY is bottom edge
                // minX is left edge
                // maxX is right Edge
                
                if contact.contactNormal.dy == 1.0  {
                    groundHit()
                } else if contact.contactNormal.dx != 0.0 {
                    wallHit()
                }
                
            default:
                break
            }


    }
    
    func endedContactWith(body: SKPhysicsBody, contact:SKPhysicsContact) {
        switch(body.categoryBitMask) {
        case BodyTypes.landscape.rawValue:
            // minY is top edge
            // maxY is bottom edge
            // minX is left edge
            // maxX is right Edge
            if(onWall) {
                wallLeave()
            } else if(onGround) {
                groundLeave()
            }
            
        default:
            break
        }

    }
    
    
}