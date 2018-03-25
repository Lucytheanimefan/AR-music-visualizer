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
    static let middleCfrequencies = (1...5).map { $0 * Constants.Notes.C4 }
    
    static let frequencyArray = [Constants.Notes.Db3,
                                 Constants.Notes.D3,
                                 Constants.Notes.Eb3,
                                 Constants.Notes.E3,
                                 Constants.Notes.F3,
                                 Constants.Notes.Gb3,
                                 Constants.Notes.G3,
                                 Constants.Notes.Ab3,
                                 Constants.Notes.A3,
                                 Constants.Notes.Bb3,
                                 Constants.Notes.B3,
                                 Constants.Notes.C4]
    
    static let shared = AudioGenerator()
    
    var oscillators:[AKOscillator]!
    
    var nodes:[AKNode] = [AKNode]()
    
    var envelope:AKAmplitudeEnvelope!
    
    var fft:AKFFTTap?
    
    override init() {
        super.init()
    }
    
    
    func delay(rampTime:Double) -> AKNode{
        let filter = AKMoogLadder(AKMicrophone())
        let delay = AKVariableDelay(filter)
        delay.rampTime = rampTime
        let delayMixer = AKDryWetMixer(filter, delay)
        let reverb = AKCostelloReverb(delayMixer)
        let reverbMixer = AKDryWetMixer(delayMixer, reverb)
        let booster = AKBooster(reverbMixer)
        return booster
    }
    
    func audioFileNode(url:URL)->AKNode?{
        do{
            let file = try AKAudioFile(forReading: url)
            let player = try AKAudioPlayer(file: file)
            player.looping = true
            return player
        } catch {
            print(error)
            return nil
        }
    }
    
    func setOutput(nodes:[AKNode]){
        var audioFileNode:AKAudioPlayer?
        let mixer = AKMixer()
        nodes.forEach { (node) in
            self.nodes.append(node)
            if let fileNode = node as? AKAudioPlayer{
                audioFileNode = fileNode
            }
            mixer.connect(input: node)
        }
        AudioKit.output = mixer
        AudioKit.start()
        if (audioFileNode != nil){
            audioFileNode?.play()
        }
        mixer.start()
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
    
    func updateOscillators(frequency:Double = Constants.Notes.C4, frequenciesArr:[Double]? = nil){
        var frequencies:[Double]!
        if (frequenciesArr == nil){
            frequencies = (1...5).map { $0 * frequency }
        }
        else{
            frequencies = frequenciesArr
        }
        
        guard frequencies.count == 5 else {
            print("Wrong length: \(frequencies.count)")
            return
        }
        //print("---")
        for (index, frequency) in frequencies.enumerated(){
            //print("Frequency: \(frequency)")
            self.oscillators[index].frequency = frequency
        }
    }
    
    func updateEnvelope(attack:Double, decay:Double, sustain:Double, release:Double){
        self.envelope.attackDuration = 0.01
        self.envelope.decayDuration = 0.1
        self.envelope.sustainLevel = 0.1
        self.envelope.releaseDuration = 0.3
    }
    
    private func applyEnvelope(node:AKNode){
        self.envelope = AKAmplitudeEnvelope(node)
        envelope.attackDuration = 0.01
        envelope.decayDuration = 0.1
        envelope.sustainLevel = 0.1
        envelope.releaseDuration = 0.3
        
        AudioKit.output = envelope
        AudioKit.start()
        envelope.start()
        self.fft = AKFFTTap(envelope)
        print("Started AudioKit audio")
    }
    
    private func createAndStartOscillator(frequency: Double) -> AKOscillator {
        let oscillator = AKOscillator()
        oscillator.frequency = frequency
        oscillator.start()
        return oscillator
    }

    
}
