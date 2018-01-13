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
    
    
    var configuration: ARWorldTrackingConfiguration!
    
    var sceneView: ARSCNView!
    
    init(sceneView: ARSCNView) {
        super.init()
        self.sceneView = sceneView
        sceneView.delegate = self
    }
    
    func initializeSceneView() {
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
//        #if DEBUG
//        sceneView.debugOptions  = [SCNDebugOptions.showConstraints, SCNDebugOptions.showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//        #endif
        
        //shows fps rate
        sceneView.showsStatistics = true
        
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func startSession() {
        configuration = ARWorldTrackingConfiguration()
        //currenly only planeDetection available is horizontal.
        configuration!.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        sceneView.session.run(configuration!, options: [ARSession.RunOptions.removeExistingAnchors,
                                                        ARSession.RunOptions.resetTracking])
        
    }
    
    func createParticleSystem() -> SCNNode?{
        var systemNode:SCNNode!
        if let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil){
            systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem)
        }
        return systemNode
    }
    
   
}

extension ARManager: ARSCNViewDelegate{
    
    
    
}
