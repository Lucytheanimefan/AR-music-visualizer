//
//  FigureManager.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/20/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import SceneKit

class FigureManager: NSObject {
    
    class func extrudePath(path: UIBezierPath, depth: Float) -> SCNShape{
        let shape = SCNShape(path: path, extrusionDepth: CGFloat(depth))
        shape.firstMaterial?.diffuse.contents = UIColor.blue // TODO: change color
        return shape
    }
    
    class func animate(shape: SCNShape, duration:Float){
        let modifier = "uniform float progress;\n #pragma transparent\n vec4 mPos = u_inverseModelViewTransform * vec4(_surface.position, 1.0);\n _surface.transparent.a = clamp(1.0 - ((mPos.x + 50.0) - progress * 200.0) / 50.0, 0.0, 1.0);"
        shape.shaderModifiers = [ SCNShaderModifierEntryPoint.surface: modifier ]
        shape.setValue(0.0, forKey: "progress")
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = Double(duration)
        shape.setValue(1.0, forKey: "progress")
        SCNTransaction.commit()
    }

}
