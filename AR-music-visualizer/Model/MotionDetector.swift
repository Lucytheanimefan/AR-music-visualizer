//
//  MotionDetector.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 2/4/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation

protocol MotionDetectorDelegate
{
    func automotiveAction(confidence:CMMotionActivityConfidence)
    func stationaryAction(confidence:CMMotionActivityConfidence)
    func standingAction(confidence:CMMotionActivityConfidence)
    func sittingAction(confidence:CMMotionActivityConfidence)
    func walkingAction(confidence:CMMotionActivityConfidence)
    func runningAction(confidence:CMMotionActivityConfidence)
    func cyclingAction(confidence:CMMotionActivityConfidence)
    func unknownAction(confidence:CMMotionActivityConfidence)
    func gyroScopeHandler(data:CMGyroData?)
    func deviceMotionUpdateHandler(deviceMotion: CMDeviceMotion?)
    func accelerometerHandler(accelData: CMAccelerometerData?)
}

class MotionDetector: NSObject {

    var activityManager:CMMotionActivityManager!
    var motionManager:CMMotionManager!
    var delegate:MotionDetectorDelegate?
    var currentDeviceMotion:CMDeviceMotion?
    var oldGravity:Double?
    //static let shared = MotionDetector()

    init(activityManager:CMMotionActivityManager, motionManager:CMMotionManager) {
        super.init()
        self.activityManager = activityManager
        self.motionManager = motionManager
    }
    
    func startActivityDetection(){
        //let activityQueue = OperationQueue()
        self.activityManager.startActivityUpdates(to: OperationQueue.current!) { (motion) in
    
            if let motion = motion{
                if (motion.automotive)
                {
                    self.delegate?.automotiveAction(confidence: motion.confidence)
                }
                else if (motion.stationary)
                {
                    if (self.currentDeviceMotion != nil){
                        if (self.oldGravity != nil){
                            print("Old gravity: \(self.oldGravity), new gravity: \(self.currentDeviceMotion!.gravity.y)")
                            if (self.currentDeviceMotion!.gravity.y < self.oldGravity! - 0.10){
                                // standing
                                self.delegate?.standingAction(confidence: motion.confidence)
                                
                            }
                            else if (self.currentDeviceMotion!.gravity.y-0.10 > self.oldGravity! ){
                                //sitting
                                self.delegate?.sittingAction(confidence: motion.confidence)
                            }
                        }
                        
                        self.oldGravity = self.currentDeviceMotion!.gravity.y
                        print("--Old gravity: \(self.oldGravity), new gravity: \(self.currentDeviceMotion!.gravity.y)")
                        
                    }else{
                        print("Just stationary")
                        self.delegate?.stationaryAction(confidence: motion.confidence)
                    }
                }
                else if (motion.walking)
                {
                    self.delegate?.walkingAction(confidence: motion.confidence)
                }
                else if(motion.running)
                {
                    self.delegate?.runningAction(confidence: motion.confidence)
                }
                else if (motion.cycling)
                {
                    self.delegate?.cyclingAction(confidence: motion.confidence)
                }
                else if (motion.unknown)
                {
                    self.delegate?.unknownAction(confidence: motion.confidence)
                }
            }
        }
    }
    
    func gyroScopeUpdate() -> Void{
        motionManager.gyroUpdateInterval = TimeInterval(Constants.updateInterval) // every 5 seconds
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (gyroData, error) in
            self.delegate?.gyroScopeHandler(data: gyroData)
        }
    }
    
    func motionUpdates() -> Void{
        motionManager.deviceMotionUpdateInterval = TimeInterval(Constants.updateInterval)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion, error) in
            self.currentDeviceMotion = deviceMotion
            self.delegate?.deviceMotionUpdateHandler(deviceMotion: deviceMotion)
        }
    }
    
    func accelerometerUpdates(){
        motionManager.accelerometerUpdateInterval = Constants.updateInterval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData, error) in
           self.delegate?.accelerometerHandler(accelData: accelerometerData)
        }
    }
}
