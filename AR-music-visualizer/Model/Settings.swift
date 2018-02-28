//
//  Settings.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/20/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func onSwitch(type:String)
}

class Settings: NSObject {
    
    var delegate: SettingsDelegate?
    
    private var _visualizationType:String = "Sphere"
    var visualizationType:String
    {
        get {
            return self._visualizationType
        }
        
        set{
            self._visualizationType = newValue
            delegate?.onSwitch(type: self._visualizationType)
        }
        
    }
    
    static let shared = Settings()
    
    var showAccelData:Bool = false
    var showGyroData:Bool = false
    var showMotionCategory:Bool = true
    var showDeviceMotionData:Bool = false

}
