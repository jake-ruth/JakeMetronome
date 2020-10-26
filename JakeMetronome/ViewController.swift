import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {
    var mixer = AKMixer();
    var sequencer = AKSequencer()
    var callbackInstrument = AKCallbackInstrument()
    
    var silencedBeats = [0, 1, 2];
    var subdivision: Int = 7;
    var tempo: Int = 200;
    
    override func viewDidLoad() {
        
        self.startMetronome();
    
        sleep(5);
        
        self.stopMetronome();
        
        self.setSubdivision(subdivision: 4);
        
        self.startMetronome();
        
        sleep(10);
        
        self.stopMetronome();
        
        sleep(2);
        
        self.setTempo(tempo: 250);
        
        self.startMetronome();
        
        sleep(10);
        
        self.stopMetronome();
  
    }
    
    @objc
    func startMetronome(){
        AKManager.output = mixer;
        
        AKSettings.playbackWhileMuted = true;
        try! AKManager.start();
        
        mixer.start();
        
        // Set up track for callbackInstrument
        let track = sequencer.addTrack(for: callbackInstrument);
        
        for i in 0 ..< subdivision {
            track.add(noteNumber: MIDINoteNumber(Int(i)), position: Double(i), duration: 0)
        }
        
        track.length = Double(subdivision)
        track.tempo = Double(self.tempo);
        track.loopEnabled = true
        track >>> mixer  // must send track to mixer
        
        let click = AKOscillatorBank(waveform: AKTable(.sine), attackDuration: 0.01, decayDuration: 0.01, sustainLevel: 0, releaseDuration: 0, pitchBend: 0, vibratoDepth: 0, vibratoRate: 0);
        
        click >>> self.mixer;
         
        callbackInstrument.callback = { status, note, vel in
            guard let status = AKMIDIStatus(byte: status),
                let type = status.type,
                type == .noteOn else { return }
            print("note on: \(note)")
            
            click.reset();
            
            if (!self.silencedBeats.contains(0) && note == 0){
                click.play(noteNumber: 95, velocity: 100)
            }
            
            else if (!self.silencedBeats.contains(Int(note))){
                click.play(noteNumber: 90, velocity: 100)
            }
        }
        
        callbackInstrument >>> mixer
        sequencer.playFromStart();
    }
    
    @objc
    func stopMetronome(){
        try! AKManager.stop();
        sequencer.clear();

    }
    
    @objc
    func setSilencedBeats(silencedBeats: [Int]){
        self.silencedBeats = silencedBeats;
    }
    
    @objc
    func setSubdivision(subdivision: Int){
        self.silencedBeats = [];
        self.subdivision = subdivision;
    }
    
    @objc
    func setTempo(tempo: Int){
        self.tempo = tempo;
    }
}
