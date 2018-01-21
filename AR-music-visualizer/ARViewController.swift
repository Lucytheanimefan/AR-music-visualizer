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
    
    @IBOutlet weak var beginButton: UIBarButtonItem!
    
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
        Settings.shared.delegate = self
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.manager = ARManager(sceneView: sceneView)
        self.manager.initializeSceneView()
        self.sceneView.pointOfView?.light = spotLight
        self.musicLoader = MusicLoader()
        self.musicLoader.delegate = self
        
        //addRibbons()
        //createInitialPath()
        //addSpheres()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.manager.startSession()
        
        if Settings.shared.visualizationType == "Sphere"{
            addSpheres()
        }
        else if Settings.shared.visualizationType == "Ribbon"{
            addRibbons()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func begin(_ sender: UIBarButtonItem) {
        self.musicLoader.begin(file: self.musicFilePath)
        self.beginButton.isEnabled = false
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.musicLoader.cancel()
        }
    }
    
    func createInitialPath(){
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addQuadCurve(to: CGPoint(x: 100, y: 0), controlPoint: CGPoint(x: 50, y: 200))
        path.addLine(to: CGPoint(x: 99, y: 0))
        path.addQuadCurve(to: CGPoint(x: 1, y: 0), controlPoint: CGPoint(x: 50, y: 198))
        let shape = FigureManager.extrudePath(path: path, depth: 10.0)
        let shapeNode = SCNNode(geometry: shape)
        shapeNode.pivot = SCNMatrix4MakeTranslation(50, 0, 0)
        shapeNode.eulerAngles.y = Float(-Double.pi/4)
        shapeNode.name = "initialRibbon"
        nodes.append(shapeNode)
        addNodeToScene(node: shapeNode)
        FigureManager.animate(shape: shape, duration: 10.0)
    }
    
    func addRibbons(){
        let incrementAngle = (8*Float.pi) / Float(Constants.FRAME_COUNT)
        for i in 0..<(Constants.FRAME_COUNT/2) {
            let x = CGFloat(cos(Float(i/2) * incrementAngle))
            let y = CGFloat(sin(Float(i/2) * incrementAngle))
            
            let radius = CGFloat(self.sceneView.frame.width/10)
            let startAngle = CGFloat(-Double.pi/2)
            let endAngle = CGFloat(1.5*Double.pi)
            
            print("Radius: \(radius)")
            
            //let path = UIBezierPath(arcCenter: CGPoint(x:CGFloat(x),y:CGFloat(y)) , radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            let path = UIBezierPath()
            path.move(to: CGPoint.zero/*CGPoint(x: 10*x, y: y)*/ )
            path.addLine(to: CGPoint(x: 10*x, y: 10*y))
//            path.addQuadCurve(to: CGPoint(x: 10*x, y: y), controlPoint: CGPoint(x: 5*x, y: 20*y))
//            path.addLine(to: CGPoint(x: 9.9*x, y: 0))
//            path.addQuadCurve(to: CGPoint(x: x, y: 0), controlPoint: CGPoint(x: 5*x, y: 19.8*y))
//

            
            let shape = FigureManager.extrudePath(path: path, depth: 10.0)
            let shapeNode = SCNNode(geometry: shape)
            shapeNode.pivot = SCNMatrix4MakeTranslation(Float(x), 0, 0)
            shapeNode.eulerAngles.y = Float(-Double.pi/4)
            shapeNode.name = "ribbon\(i)"
            nodes.append(shapeNode)
            addNodeToScene(node: shapeNode)
        }
    }
    
    func addSpheres(){
        let incrementAngle = CGFloat((8*Float.pi) / Float(Constants.FRAME_COUNT))
        for i in 0..<(Constants.FRAME_COUNT/2) {
            let x = cos(CGFloat(i/2) * incrementAngle)
            let y = sin(CGFloat(i/2) * incrementAngle)
            let node = addSphereNode(position: SCNVector3Make(Float(x), Float(y), /*Float(i) * 0.05*/-2))
            nodes.append(node)
        }
    }
    
    func addParticleNode(position: SCNVector3) -> SCNNode?{
        if let particleNode = manager.createParticleSystem(){
            particleNode.position = position
            addNodeToScene(node: particleNode)
            //os_log("%@: Added particle system", self.description)
            return particleNode
        }
        return nil
    }
    
    func addSphereNode(position: SCNVector3) -> SCNNode{
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = sphere
        node.position = position
        addNodeToScene(node: node)
        return node
    }

    
    func addNodeToScene(node:SCNNode){
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first!
//        let location = touch.location(in: sceneView)
//        let hitResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .featurePoint])
//        if hitResults.count > 0 {
//            let result: ARHitTestResult = hitResults.first!
//            let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y/3, result.worldTransform.columns.3.z)
//            //addParticleNode(position: newLocation)
//            addSphereNode(position: newLocation)
//        }
//    }
    

}

extension ARViewController: MusicLoaderDelegate{
    func onPlay() {
        
    }
    
    func dealWithFFTMagnitudes(magnitudes: [Float]) {
        #if DEBUG
        //print("Magnitude count: \(magnitudes.count)")
        #endif
        
        for (index, magnitude) in magnitudes.enumerated()
        {
            if Settings.shared.visualizationType == "Sphere"{
                updateNodeScalesWithFFT(index: index, magnitude: magnitude)
            }
            else if Settings.shared.visualizationType == "Ribbon"{
                updateRibbonNodes(index: index, magnitude: magnitude)
            }

        }
        
    }

    func updateRibbonNodes(index:Int, magnitude:Float){
        guard nodes.count > index else {
            return
        }
        if let shape = nodes[index].geometry as? SCNShape{
            FigureManager.animate(shape: shape, duration: magnitude * 10000)
        }

    }
    
    func updateNodeScalesWithFFT(index:Int, magnitude:Float){
        
        let m = magnitude*10
        
        let s = SCNVector3Make(m, m, m)
        nodes[index].scale = s
        
        //let q = SCNVector4Make(m, m, m, m)
        //nodes[index].rotate(by: q, aroundTarget: rotate)
        
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

extension ARViewController: SettingsDelegate {
    func onSwitch(type: String) {
        // Remove all nodes
        removeAllNodes()
    }
    
    func removeAllNodes(){
        self.sceneView.scene.rootNode.childNodes.forEach { (node) in
            node.removeFromParentNode()
        }
    }
}
