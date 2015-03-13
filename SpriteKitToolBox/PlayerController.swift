//
//  PlayerControls.swift
//  SpriteKitToolBox
//
//  Created by Jeremy Dowell on 3/11/15.
//  Copyright (c) 2015 Jeremy Dowell. All rights reserved.
//

import Foundation
import SpriteKit

enum MoveDirections {
    case None
    case Left
    case Right
    case Up
    case Down
}

class PlayerController {
    var isMoving = false
    var movements:Array<MoveDirections> = Array<MoveDirections>()
    var jumpStartTime:CFTimeInterval = 0.0
    var jumpTimer:CFTimeInterval = 0.0

    var currentTime:CFTimeInterval = 0.0
    var frame:CGRect = CGRect.zeroRect
    var jumpsRemaining = 0
    
    func jump(event:UIEvent) {
        if(jumpsRemaining > 0) {
            movements.removeObject(MoveDirections.Up)
            movements.append(MoveDirections.Up)
            jumpStartTime = event.timestamp
            jumpsRemaining--
        }
    }
    
    func stopJump() {
        movements.removeObject(MoveDirections.Up)
        jumpStartTime = 0.0
        
    }
    
    func move(direction:MoveDirections) {
        movements.removeObjects(MoveDirections.Left, MoveDirections.Right)
        movements.append(direction)
    }
    
    func stopMove() {
        movements.removeObjects(MoveDirections.Left, MoveDirections.Right)
        movements.append(MoveDirections.None)
    }
    
    
    func touchesBegan(touchLocation:CGPoint, event:UIEvent) {
        if(touchLocation.x > self.frame.width / 2) {
            jump(event)
        } else { // other wise the player should move
            if(touchLocation.x <= self.frame.width / 4) {
                move(MoveDirections.Left)
            } else {
                move(MoveDirections.Right)
            }
        }
    }
    
    func touchesMoved(touchLocation:CGPoint, previousLocation:CGPoint, event:UIEvent) {
        if(touchLocation.x > self.frame.width / 2) {
            if(previousLocation.x < self.frame.width / 2) {
                stopMove()
            }
        } else { // other wise the player should move
            if(touchLocation.x <= self.frame.width / 4) {
                move(MoveDirections.Left)
            } else {
                move(MoveDirections.Right)
            }
        }
        
    }
    
    func touchesEnded(touchLocation:CGPoint, event:UIEvent) {
        if(touchLocation.x > self.frame.width / 2) {
            stopJump()
        } else {
            stopMove()
        }
    }
    
    
}