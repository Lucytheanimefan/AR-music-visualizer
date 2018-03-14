//
//  ViewController.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/8/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

import os.log

class ViewController: UIViewController {

    @IBOutlet weak var visualizationButton: UIButton!
    
    // Choosing existing music from itunes
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    var musicAssetURL:URL!

    var motionDetector:MotionDetector!
    
    @IBOutlet weak var debugView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.recordingSession = AVAudioSession.sharedInstance()

   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func displayMediaPicker(){
        mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        
        if let picker = mediaPicker{
            picker.delegate = self
            view.addSubview(picker.view)
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            self.presentMessage(title: "Error", message: "Couldn't instantiate a media picker")
        }
    }
    
    @IBAction func openItunesLibrary(_ sender: UIButton) {
        displayMediaPicker()
    }

    
    @IBAction func goToVisualization(_ sender: UIButton) {
        performSegue(withIdentifier: "ARVisualizationSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ARViewController{
            vc.musicFilePath = self.musicAssetURL
        }
    }
    
}

extension ViewController: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            //finishRecording(success: false)
        }
    }
}

extension ViewController: MPMediaPickerControllerDelegate{
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //        myMusicPlayer = MPMusicPlayerController()
        //
        //        if let player = myMusicPlayer{
        //myMusicPlayer!.beginGeneratingPlaybackNotifications()
        //myMusicPlayer!.setQueue(with: mediaItemCollection)
        //
        
        // Get the file
        let musicItem = mediaItemCollection.items[0]
        if let assetURL = musicItem.value(forKey: MPMediaItemPropertyAssetURL) as? URL
        {
            self.musicAssetURL = assetURL
            self.visualizationButton.isHidden = false
            self.debugView.text = assetURL.absoluteString
        }
        
        
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController{
    
    func presentMessage(title:String, message:String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        return alert
    }
}


