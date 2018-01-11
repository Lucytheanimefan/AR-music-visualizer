//
//  FFTTransformer.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 1/11/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import AVFoundation
import Accelerate
import os.log

protocol Transformer {
    func transform(buffer: AVAudioPCMBuffer) -> Buffer
}

final class FFTTransformer: Transformer {
    func transform(buffer: AVAudioPCMBuffer) -> Buffer {
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
    
    // MARK: - Helpers
    func sqrtq(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        
        return results
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
