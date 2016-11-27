//
//  Newrecord.swift
//  Siri
//
//  Created by JJ on 2016. 11. 26..
//  Copyright © 2016년 Sahand Edrisian. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire


class Newrecord: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {

    
    //TODO : Upload....
    
    
    
    
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBAction func Play(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Play"{
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            
            preparePlayer()
            audioPlayer.play()
        }
        else{
            sender.setTitle("Play", for: .normal)
            
        }

    }
    @IBAction func Upload(_ sender: UIButton) {
        self.upload()
    }
    
 
    func upload() {
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let fileURL = Bundle.main.url(forResource:"document",withExtension:"wav")
        
        
        Alamofire.upload(audioFilename, to: "http://163.239.169.54:5000/uploads")
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            .downloadProgress { progress in // main queue by default
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseJSON { response in
                print("response : ",response)
        }
        
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("http://163.239.169.54:5000/uploads").responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            if ((response.response!.statusCode) >= 200 && (response.response!.statusCode) < 300){
                print("Success")
            }
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
        
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }

        // Do any additional setup after loading the view.
    }
    
    func preparePlayer(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        do{audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)}
        catch{
            print("asdfasdf")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 1.0
    }

    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatULaw),
            AVSampleRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Rec", for: .normal)
        } else {
            recordButton.setTitle("Rec", for: .normal)
            // recording failed :(
        }
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadRecordingUI() {
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playBtn.setTitle("Play", for: .normal)
    }
    

}
