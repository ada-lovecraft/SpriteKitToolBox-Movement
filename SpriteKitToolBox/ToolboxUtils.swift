//
//  ToolboxUtils.swift
//  SpriteKitToolBox
//
//  Created by Jeremy Dowell on 3/10/15.
//  Copyright (c) 2015 Jeremy Dowell. All rights reserved.
//

import Foundation
import SpriteKit

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if((index) != nil) {
            self.removeAtIndex(index!)
        }
    }
    mutating func removeObjects<U: Equatable>(objects: U...) {
        for object in objects {
            removeObject(object)
        }
    }
}

extension String
{
    subscript(integerIndex: Int) -> Character
        {
            let index = advance(startIndex, integerIndex)
            return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String
        {
            let start = advance(startIndex, integerRange.startIndex)
            let end = advance(startIndex, integerRange.endIndex)
            let range = start..<end
            return self[range]
    }
}



extension SKColor {
    convenience init(r:Int, g:Int, b:Int, a:CGFloat) {
        let red:CGFloat = CGFloat(r) / 255
        let green:CGFloat = CGFloat(g) / 255
        let blue:CGFloat = CGFloat(b) / 255
        self.init(red: red, green: green, blue: blue, alpha: a)
    }
    
    convenience init(var fromCSS:String) {
        var str = fromCSS
        if str.rangeOfString("#") != nil {
            str = str.substringFromIndex(advance(str.startIndex,1))
        }
        assert(count(str) == 6, "Not a valid css color string: \(fromCSS)")
        let r = Int(strtoul(str[0...1],nil, 16))
        let g = Int(strtoul(str[2...3],nil, 16))
        let b = Int(strtoul(str[4...5],nil, 16))
        
        self.init(r: r, g: g, b: b, a: 1.0)
    }
}

extension String {
    func toInt(base:Int) {
        
    }
}