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
    
    var currentDeviceMotion:CMDeviceMotion?
    var oldGravity:Double?
    var oldStationaryStatus:String = "Stationary"
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
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let time = dateFormatter.string(from: Date())
        self.tableViewData.appendHandler(newElement: "\(time): \(newStuff)") {
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
        let text = tableViewData[indexPath.row]
        cell.textView.text = text
        if (text.contains("Confidence")){
            cell.backgroundColor = UIColor.green
        }
        else{
            cell.backgroundColor = .clear
        }
        return cell
    }
    
}

extension MotionViewController: MotionDetectorDelegate{
    func automotiveAction(confidence: CMMotionActivityConfidence) {
        appendToTableView(newStuff: "Automotive, Confidence: \(confidenceMap[confidence.rawValue])")
    }
    
    func stationaryAction(confidence: CMMotionActivityConfidence) {
        
        if (self.currentDeviceMotion != nil){
            if (oldGravity != nil){
                if (self.currentDeviceMotion!.gravity.y < oldGravity! - 0.10){
                    // standing
                    oldStationaryStatus = "Standing"
                }
                else if (self.currentDeviceMotion!.gravity.y-0.10 > oldGravity! ){
                    //sitting
                    oldStationaryStatus = "Sitting"
                }
            }
            
            oldGravity = self.currentDeviceMotion!.gravity.y
        }
        
        appendToTableView(newStuff: "\(oldStationaryStatus), Confidence: \(confidenceMap[confidence.rawValue])")
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
            self.currentDeviceMotion = deviceMotion
            self.tableViewData.insert("Rotation rate: \(deviceMotion!.rotationRate.x.rounded()),\(deviceMotion!.rotationRate.y.rounded()),\(deviceMotion!.rotationRate.z.rounded())", at:0)
            self.tableViewData.insert("Acceleration: \(round(deviceMotion!.userAcceleration.x * 100)/100),\(round(deviceMotion!.userAcceleration.y*100)/100), \(round(deviceMotion!.userAcceleration.z * 100)/100)", at:0)
            self.tableViewData.insert("Gravity: \(round(deviceMotion!.gravity.x * 100)/100),\(round(deviceMotion!.gravity.y*100)/100),\(round(deviceMotion!.gravity.z*100)/100)", at:0)
            
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
        insert(newElement, at: 0)
        //append(newElement)
        handler()
    }
}

