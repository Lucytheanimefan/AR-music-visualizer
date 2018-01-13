//
//  ARManager.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/12/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import ARKit
class ARManager: NSObject {
    
    static let shared = ARManager()
    
    func initializeSceneView(sceneView: ARSCNView) {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create new scene and attach the scene to the sceneView
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        // Add the SCNDebugOptions options
        // showConstraints, showLightExtents are SCNDebugOptions
        // showFeaturePoints and showWorldOrigin are ARSCNDebugOptions
        //sceneView.debugOptions  = [SCNDebugOptions.showConstraints, SCNDebugOptions.showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        //shows fps rate
        sceneView.showsStatistics = true
        
        sceneView.automaticallyUpdatesLighting = true
    }
    
}

extension ARManager: ARSCNViewDelegate{
    
}
