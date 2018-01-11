//
//  FFTViewController.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/11/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate
import MediaPlayer

class FFTViewController: UIViewController {

    var audioEngine = AVAudioEngine()
    var audioNode = AVAudioPlayerNode()
    var magnitudes:[Float]!
    
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        audioEngine.attach(audioNode)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func begin(file:URL){
        guard let audioFile = try? AVAudioFile(forReading: file) else {
            os_log("%@: Invalid file: %@", self.description, file.absoluteString)
            return
        }
        if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                         frameCapacity: AVAudioFrameCount(audioFile.length)){
            try? audioFile.read(into: buffer)
            audioEngine.connect(audioNode, to: audioEngine.mainMixerNode, format: buffer.format)
            audioNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            retrieveAudioBuffer()
        }
    }
    
    func retrieveAudioBuffer(){
        let size: UInt32 = 1024
        let mixerNode = audioEngine.mainMixerNode
        
        // observe the output of the player node
        mixerNode.installTap(onBus: 0,
                             bufferSize: size,
                             format: mixerNode.outputFormat(forBus: 0)) { (buffer, time) in self.fftTransform(buffer: buffer)
        }
        
        //FFTTransformer().transform(buffer: <#T##AVAudioPCMBuffer#>)
        audioEngine.prepare()
        do
        {
            try audioEngine.start()
            
            audioNode.play()
        }
        catch
        {
            os_log("%@: Error starting audio engine %@", type: .error, self.description, error.localizedDescription)
        }
    }
    
    func fftTransform(buffer: AVAudioPCMBuffer) -> Buffer {
        print("FFT transform")
        let frameCount = buffer.frameLength
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        let windowSize = bufferSizePOT
        var transferBuffer = [Float](repeating: 0, count: windowSize)
        var window = [Float](repeating: 0, count: windowSize)
        
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        let temp = UnsafePointer<Float>(transferBuffer)
        
        temp.withMemoryRebound(to: DSPComplex.self, capacity: transferBuffer.count) { (typeConvertedTransferBuffer) -> Void in
            vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(inputCount))
        }
        
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(inputCount)],
                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))
        
        let buffer = Buffer(elements: normalizedMagnitudes)
        
        vDSP_destroy_fftsetup(fftSetup)
        
        print("BUFFER")
        print(buffer)
        return buffer
    }
    
    func performFFT(buffer: AVAudioPCMBuffer) {
        print("Perform FFT")
        let frameCount = buffer.frameLength
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        let windowSize = bufferSizePOT
        var transferBuffer = [Float](repeating: 0, count: windowSize)
        var window = [Float](repeating: 0, count: windowSize)
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul((buffer.floatChannelData?.pointee)!, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        // Transforming the [Float] buffer into a UnsafePointer<Float> object for the vDSP_ctoz method
        // And then pack the input into the complex buffer (output)
        let temp = UnsafePointer<Float>(transferBuffer)
        temp.withMemoryRebound(to: DSPComplex.self,
                               capacity: transferBuffer.count) {
                                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(inputCount))
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(inputCount))
        
        // Normalising
        var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
        vDSP_vsmul(sqrtq(magnitudes), 1, [2.0 / Float(inputCount)],
                   &normalizedMagnitudes, 1, vDSP_Length(inputCount))
        
        self.magnitudes = magnitudes
        os_log("%@: FFT magnitudes: %@", self.description, magnitudes)
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
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

extension FFTViewController: MPMediaPickerControllerDelegate{
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
                //self.debugView.text = assetURL.absoluteString
               self.begin(file: assetURL)
                
                
                
                //self.debugView.text.append(musicLoader.magnitudes.description)
            }
            
            
            mediaPicker.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
