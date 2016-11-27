//
//  Recoder.swift
//  Siri
//
//  Created by JJ on 2016. 11. 24..
//  Copyright © 2016년 Sahand Edrisian. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}

class Recoder: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    
    @IBOutlet weak var recBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    
    var recorder : AVAudioRecorder!
    var player : AVAudioPlayer!
   
    var filename = "audiofile.pcm"

    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view.
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder.delegate = self
            recorder.record()
            
            recBtn.setTitle("Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    
    func setupRecoder(){
        let recordSettings =  [
                                AVFormatIDKey: kAudioFormatALaw,
                                AVSampleRateKey: 12000,
                                AVNumberOfChannelsKey: 1,
                                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                ] as [String : Any]
        var _error : NSError?
        
        do{
            recorder = try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
        
        }
            
        catch{
            print("something wrong")
        }
        
        recorder.delegate = self
        recorder.prepareToRecord()
        
    }
    
    func getDocumentsDirectory()->URL{
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        recorder.stop()
        recorder = nil
        
        if success {
            recBtn.setTitle("Rec", for: .normal)
        } else {
            recBtn.setTitle("Rec", for: .normal)
            // recording failed :(
        }
    }
    
    
    
    func getFileURL() -> URL{
        let path = getDocumentsDirectory()
        
        
        return path
    }
  
    @IBAction func rec(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Rec"{
            recorder.record()
            sender.setTitle("Stop", for: .normal)
            playBtn.isEnabled = false
            
    }
        else{
            recorder.stop()
            sender.setTitle("Rec", for: .normal)
        }
    
    }
    @IBAction func play(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play"{
            recBtn.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            
            preparePlayer()
            player.play()
        }
        else{
            sender.setTitle("Play", for: .normal)
            
        }
    }
    
    func preparePlayer(){
        do{player = try AVAudioPlayer(contentsOf: getFileURL())}
        catch{
            print("asdfasdf")
        }
        
        player.delegate = self
        player.prepareToPlay()
        player.volume = 1.0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recBtn.isEnabled = true
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playBtn.isEnabled = true
        playBtn.setTitle("Play", for: .normal )
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
