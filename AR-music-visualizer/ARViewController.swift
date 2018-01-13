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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.musicLoader = MusicLoader()
        self.musicLoader.delegate = self

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func begin(_ sender: UIBarButtonItem) {
        self.musicLoader.begin(file: self.musicFilePath)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ARViewController: MusicLoaderDelegate{
    func onPlay() {
        
    }
    
    func dealWithFFTMagnitudes(magnitudes: [Float]) {
        //os_log("%@: FFT: %@", self.description, magnitudes)
    }
    
    
}
