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

    // Recording music
    @IBOutlet weak var recordButton: UIButton!
//    var recordingSession: AVAudioSession!
//    var audioRecorder: AVAudioRecorder!
    
    // Choosing existing music from itunes
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    var musicLoader:MusicLoader!

    @IBOutlet weak var debugView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.recordingSession = AVAudioSession.sharedInstance()
        musicLoader = MusicLoader()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func requestRecording(){
//        do {
//            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try recordingSession.setActive(true)
//            recordingSession.requestRecordPermission() { [unowned self] allowed in
//                DispatchQueue.main.async {
//                    if allowed {
//
//                    } else {
//                        self.presentMessage(title: "Error", message: "Failed to record")
//                    }
//                }
//            }
//        } catch {
//            // failed to record!
//        }
//    }
//
//    func startRecording() {
//        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
//
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.delegate = self
//            audioRecorder.record()
//
//            recordButton.setTitle("Tap to Stop", for: .normal)
//        } catch {
//            finishRecording(success: false)
//        }
//    }
//
//    func finishRecording(success: Bool){
//        audioRecorder.stop()
//        audioRecorder = nil
//
//        let title = success ? "Tap to Re-record" : "Tap to record"
//        recordButton.setTitle(title, for: .normal)
//
//    }
//
//    @IBAction func recordAction(_ sender: UIButton) {
//        if audioRecorder == nil
//        {
//            startRecording()
//        }
//        else
//        {
//            finishRecording(success: true)
//        }
//    }
    
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
        myMusicPlayer = MPMusicPlayerController()
        print(mediaItemCollection)
        if let player = myMusicPlayer{
            //player.beginGeneratingPlaybackNotifications()
            //player.setQueue(with: mediaItemCollection)
            //player.play()
            
            // Get the file
            let musicItem = mediaItemCollection.items[0]
            if let assetURL = musicItem.value(forKey: MPMediaItemPropertyAssetURL) as? URL
            {
                self.debugView.text = assetURL.absoluteString
                musicLoader.begin(file: assetURL)
    
                
                
                //self.debugView.text.append(musicLoader.magnitudes.description)
            }
            
            
            mediaPicker.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension UIViewController{
    
    func presentMessage(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
