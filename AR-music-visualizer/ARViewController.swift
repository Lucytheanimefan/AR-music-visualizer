//
//  ARViewController.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/12/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import ARKit
import os.log

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    var musicFilePath:URL!
    
    var musicLoader:MusicLoader!
    
    var manager: ARManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.manager = ARManager(sceneView: sceneView)
        self.manager.initializeSceneView()
        self.musicLoader = MusicLoader()
        self.musicLoader.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.manager.startSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func begin(_ sender: UIBarButtonItem) {
        self.musicLoader.begin(file: self.musicFilePath)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.musicLoader.cancel()
        }
    }
    
    func addParticleNode(position: SCNVector3){
        if let particleNode = manager.createParticleSystem(){
            particleNode.position = position
            self.sceneView.scene.rootNode.addChildNode(particleNode)
            os_log("%@: Added particle system", self.description)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y/3, result.worldTransform.columns.3.z)
            addParticleNode(position: newLocation)
        }
    }
    

}

extension ARViewController: MusicLoaderDelegate{
    func onPlay() {
        
    }
    
    func dealWithFFTMagnitudes(magnitudes: [Float]) {
        //os_log("%@: FFT: %@", self.description, magnitudes)
    }
}

extension ARViewController: SCNPhysicsContactDelegate{
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        if let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil){
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem)
            systemNode.position = contact.nodeA.position
            sceneView.scene.rootNode.addChildNode(systemNode)
            
            // Remove objects involved in collision
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
        }
    }
}
