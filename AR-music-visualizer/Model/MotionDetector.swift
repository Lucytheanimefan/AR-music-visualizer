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
    func automotiveAction()
    func stationaryAction()
    func walkingAction()
    func runningAction()
    func cyclingAction()
    func unknownAction()
    func gyroScopeHandler(data:CMGyroData?)
    func deviceMotionUpdateHandler(deviceMotion: CMDeviceMotion?)
    func accelerometerHandler(accelData: CMAccelerometerData?)
}

class MotionDetector: NSObject {

    let activityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    var delegate:MotionDetectorDelegate?
    
    static let shared = MotionDetector()

    
    func startActivityDetection(){
        //let activityQueue = OperationQueue()
        self.activityManager.startActivityUpdates(to: OperationQueue.current!) { (motion) in
            if let motion = motion{
                if (motion.automotive)
                {
                    self.delegate?.automotiveAction()
                }
                else if (motion.stationary)
                {
                    self.delegate?.stationaryAction()
                }
                else if (motion.walking)
                {
                    self.delegate?.walkingAction()
                }
                else if(motion.running)
                {
                    self.delegate?.runningAction()
                }
                else if (motion.cycling)
                {
                    self.delegate?.cyclingAction()
                }
                else if (motion.unknown)
                {
                    self.delegate?.unknownAction()
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
