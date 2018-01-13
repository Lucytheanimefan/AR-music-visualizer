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
    
    var nodes:[SCNNode] = [SCNNode]()
    
    fileprivate lazy var spotLight: SCNLight = {
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 0
        spotLight.spotOuterAngle = 45
        spotLight.castsShadow = true
        return spotLight
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.manager = ARManager(sceneView: sceneView)
        self.manager.initializeSceneView()
        self.sceneView.pointOfView?.light = spotLight
        self.musicLoader = MusicLoader()
        self.musicLoader.delegate = self
        
        //addSphereNode()
        let incrementAngle = CGFloat((8*Float.pi) / Float(Constants.FRAME_COUNT))
        for i in 0..<(Constants.FRAME_COUNT/2) {
            let x = cos(CGFloat(i/2) * incrementAngle)
            let y = sin(CGFloat(i/2) * incrementAngle)
            addSphereNode(position: SCNVector3Make(Float(x), Float(y), /*Float(i) * 0.05*/-2))
        }
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
            nodes.append(particleNode)
            particleNode.position = position
            addNodeToScene(node: particleNode)
            os_log("%@: Added particle system", self.description)
        }
    }
    
    func addSphereNode(position: SCNVector3){
        let size = 0.05
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = sphere
        node.position = position
        nodes.append(node)
        addNodeToScene(node: node)
    }
    
    func addNodeToScene(node:SCNNode){
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .featurePoint])
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y/3, result.worldTransform.columns.3.z)
            //addParticleNode(position: newLocation)
            addSphereNode(position: newLocation)
        }
    }
    

}

extension ARViewController: MusicLoaderDelegate{
    func onPlay() {
        
    }
    
    func dealWithFFTMagnitudes(magnitudes: [Float]) {
        let rotate = SCNVector3Make(0, 0, 0)
        //os_log("%@: FFT: %@", self.description, magnitudes)
        
        print("Magnitude count: \(magnitudes.count)")
        for (index, magnitude) in magnitudes.enumerated(){
            let m = magnitude*10
            
            let s = SCNVector3Make(m, m, m)
            nodes[index].scale = s
                //let q = SCNVector4Make(m, m, m, m)
            //nodes[index].rotate(by: q, aroundTarget: rotate)
        }
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
