//
//  MotionViewController.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 2/28/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import CoreMotion

class MotionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    

    var tableViewData = [String]()
    var motionDetector:MotionDetector!
    
    var confidenceMap = ["low", "medium", "high"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionDetector = MotionDetector(activityManager: CMMotionActivityManager(), motionManager: CMMotionManager())
        self.motionDetector.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Start motion stuff
        self.motionDetector.startActivityDetection()
        self.motionDetector.motionUpdates()
        //self.motionDetector.gyroScopeUpdate()
        //self.motionDetector.accelerometerUpdates()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tableViewData.removeAll()
    }
    
    func appendToTableView(newStuff:String){
        self.tableViewData.appendHandler(newElement: newStuff) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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

extension MotionViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "motionDataCell") as! DataTableViewCell
        cell.label.text = tableViewData[indexPath.row]
        return cell
    }
    
}

extension MotionViewController: MotionDetectorDelegate{
    func automotiveAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Automotive, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func stationaryAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Stationary, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func walkingAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Walking, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func runningAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Running, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func cyclingAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Cycling, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func unknownAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Unknown, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
   
    func gyroScopeHandler(data: CMGyroData?) {
        if (!Settings.shared.showGyroData){
            return
        }
        //self.tableViewData.append("Rotation rate: \(data?.rotationRate.x),\(data?.rotationRate.y),\(data.rotationRate.z)")
    }
    
    func deviceMotionUpdateHandler(deviceMotion: CMDeviceMotion?) {
        if (!Settings.shared.showDeviceMotionData){
            return
        }
        
        if (deviceMotion != nil){
            self.tableViewData.append("Rotation rate: \(deviceMotion!.rotationRate.x),\(deviceMotion!.rotationRate.y),\(deviceMotion!.rotationRate.z)")
            self.tableViewData.append("Acceleration: \(deviceMotion!.userAcceleration.x),\(deviceMotion!.userAcceleration.y), \(deviceMotion!.userAcceleration.z)")
            self.tableViewData.append("Gravity: \(deviceMotion!.gravity.x),\(deviceMotion!.gravity.y),\(deviceMotion!.gravity.z)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    func accelerometerHandler(accelData: CMAccelerometerData?) {
        if (!Settings.shared.showAccelData){
            return
        }
    }
}


extension Array{
    
    mutating func appendHandler(newElement: Element, handler:()->()){
        append(newElement)
        handler()
    }
}

