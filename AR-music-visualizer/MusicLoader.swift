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

protocol MusicLoaderDelegate{
    func onPlay()
    
    func dealWithFFTMagnitudes(magnitudes:[Float])
}

class MusicLoader: NSObject {
    

    var audioEngine = AVAudioEngine()
    var audioNode = AVAudioPlayerNode()
    
    var magnitudes:[Float]!
    
    var musicPath:URL!
    
    var delegate: MusicLoaderDelegate!
    
//    override init() {
//        super.init()
//
//    }

    
    func begin(file:URL){
        os_log("%@: Begin", self.description)
        audioEngine.attach(audioNode)

        
        guard let audioFile = try? AVAudioFile(forReading: file) else {
            os_log("%@: Invalid file: %@", self.description, (file.absoluteString))
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

    func cancel(){
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.detach(audioNode)
    }
    
    private func retrieveAudioBuffer(){
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
            
            os_log("%@: PLAY", self.description)
            //delegate.onPlay()
        }
        catch
        {
            os_log("%@: Error starting audio engine %@", type: .error, self.description, error.localizedDescription)
        }
    }
    
    private func fftTransform(buffer: AVAudioPCMBuffer)/* -> [Float]*/ {
        print("FFT transform")
        let frameCount = Constants.FRAME_COUNT//buffer.frameLength
        //print("Frame count: \(frameCount)")
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n)
        let inputCount = bufferSizePOT / 2
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        var realp = [Float](repeating: 0, count: inputCount)
        var imagp = [Float](repeating: 0, count: inputCount)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        // This is the value the web app uses
        let windowSize = bufferSizePOT
        
        
        //print("Window size: \(windowSize)")
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
        
        delegate.dealWithFFTMagnitudes(magnitudes: normalizedMagnitudes)
        
        #if DEBUG
        os_log("%@: FFT magnitudes: %@", self.description,  normalizedMagnitudes)
        #endif
        
        //let buffer = Buffer(elements: normalizedMagnitudes)
        
        vDSP_destroy_fftsetup(fftSetup)
   
        //return buffer.elements
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

struct Buffer {
    var elements: [Float]
    var realElements: [Float]?
    var imagElements: [Float]?
    
    var count: Int {
        return elements.count
    }
    
    // MARK: - Initialization
    init(elements: [Float], realElements: [Float]? = nil, imagElements: [Float]? = nil) {
        self.elements = elements
        self.realElements = realElements
        self.imagElements = imagElements
    }
}
