//
//  Sequencer.swift
//  JakeMetronome
//
//  Created by Admin on 10/25/20.
//

import Foundation
import AudioKit

class SequencerWrapper {
    var seq: AKSequencer!
    var cbInst: AKCallbackInstrument!
    var mixer: AKMixer!
    let sample: AKOperation!

    init() {
        mixer = AKMixer()
        AKManager.output = mixer
        seq = AKSequencer()
        cbInst = AKCallbackInstrument()
        sample = AKOperation.sineWave(frequency: 1000, amplitude: 100);

        // set up a track
        let track = seq.addTrack(for: cbInst)
        for i in 0 ..< 4 {
            track.add(noteNumber: MIDINoteNumber(Int(i)), position: Double(i), duration: 0.5)
//            sample.play(noteNumber: 10, velocity: MIDIVelocity(100), channel: 1)
        }
        track.length = 4.0
        track.loopEnabled = true
        track >>> mixer  // must send track to mixer

        // set up the callback instrument
        cbInst.callback = { status, note, vel in
            guard let status = AKMIDIStatus(byte: status),
                let type = status.type,
                type == .noteOn else { return }
            print("note on: \(note)")
            // trigger sampler etc from here
        }
        cbInst >>> mixer // must send callbackInst to mixer
    }

    func play() {
        print("in play");
        
        try! AKManager.start();
        seq.playFromStart()
    }
}
