//
//  DebugView.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 2/4/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit

class DebugView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var textView: UITextView?
    
    func minimizeView(){
        self.frame.size.height = 0
//        var newFrame = self.frame
//        newFrame.size.height = 0
//        self.frame = newFrame
    }

    func maximizeView(){
        self.frame.size.height = 100
    }
    
    func addTextView(){
        self.textView = UITextView(frame: self.frame)
        self.addSubview(textView!)
    }
}
