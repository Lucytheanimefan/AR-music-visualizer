//
//  AudioGenerator.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 3/14/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import AudioKit
class AudioGenerator: NSObject {
    
    //It’s the frequency of middle C on a standard keyboard. The other frequencies are multiples of this value, which are known as harmonics.
    static let middleCfrequencies = (1...5).map { $0 * 261.63 }
    
    static let shared = AudioGenerator()
    
    var oscillators:[AKOscillator]!
    
    override init() {
        super.init()
    }
    
    func generateOscillatorsMixer(frequencies:[Double]){
        self.oscillators = frequencies.map {
            createAndStartOscillator(frequency: $0)
        }
        let mixer = AKMixer()
        oscillators.forEach { (oscillator) in
            mixer.connect(input: oscillator)
        }
        
        applyEnvelope(node: mixer)
    }
    
    func applyEnvelope(node:AKNode){
        let envelope = AKAmplitudeEnvelope(node)
        envelope.attackDuration = 0.01
        envelope.decayDuration = 0.1
        envelope.sustainLevel = 0.1
        envelope.releaseDuration = 0.3
        
        AudioKit.output = envelope
        AudioKit.start()
        envelope.start()
        print("Started AudioKit audio")
    }
    
    func createAndStartOscillator(frequency: Double) -> AKOscillator {
        let oscillator = AKOscillator()
        oscillator.frequency = frequency
        oscillator.start()
        return oscillator
    }

    
}
