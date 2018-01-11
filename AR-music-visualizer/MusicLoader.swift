//
//  MusicLoader.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/11/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import AVFoundation
import Accelerate
import os.log

class MusicLoader: NSObject {

    let audioEngine = AVAudioEngine()
    let audioNode = AVAudioPlayerNode()
    
    var magnitudes:[Float]!
    
    init(filePath:URL) {
        audioEngine.attach(audioNode)

        guard let url = Bundle.main.url(forResource: "angel_beats_short", withExtension: "wav") else { return }
        guard let audioFile = try? AVAudioFile(forReading: /*filePath*/ url) else { return }
        if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                         frameCapacity: AVAudioFrameCount(audioFile.length)){
            try? audioFile.read(into: buffer)
            audioEngine.connect(audioNode, to: audioEngine.mainMixerNode, format: buffer.format)
            audioNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        }
    }

    func retrieveAudioBuffer(){
        let size: UInt32 = 1024
        let mixerNode = audioEngine.mainMixerNode
        
        // observe the output of the player node
        mixerNode.installTap(onBus: 0,
                             bufferSize: size,
                             format: mixerNode.outputFormat(forBus: 0)) { (buffer, time) in
                                self.performFFT(buffer: buffer)
        }
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        } catch{
            os_log("%@: Error starting audio engineL %@", self.description, error.localizedDescription)
        }
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
    
    
}

extension String {
    
    func fileName() -> String {
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        }
        return ""
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        }
        return ""
        
    }
}
