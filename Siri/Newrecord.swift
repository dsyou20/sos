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
    
    
    //var audioFilename = getDocumentsDirectory().appendingPathComponent("recording.pcm")

    
    @IBOutlet weak var resultLabel: UILabel!
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
        uploadBtn.setTitle("...", for: .normal)
        self.upload()
        
    }
    
 
    func upload() {
        var audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        Alamofire.request("http://163.239.169.54:5000/uploads").responseString { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            if ((response.response!.statusCode) >= 200 && (response.response!.statusCode) < 300){
                print("Success")
            }
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
              //  let fileURL = Bundle.main.url(forResource:"document",withExtension:"pcm")
        var serverURL : URLRequest

        do{
            try! serverURL =  URLRequest(url: "http://163.239.169.54:5000/uploads", method: .get)
        }
        catch{}
       
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(audioFilename, withName: "file")
        },
            to: "http://163.239.169.54:5000/uploads",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //print(response["Result"])
                        //print(response.result)
                        print(response.result.value as! Int)
                        self.resultLabel.text = "\(response.result.value)"
                        print(self.resultLabel.text )
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
 
 
 
        uploadBtn.setTitle("Upload", for: .normal)
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("http://163.239.169.54:5000/uploads").responseString { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
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
            recordingSession.requestRecordPermission() { [unowned self] allowed in          // 마이크 승인여부
                DispatchQueue.main.async {
                    if allowed {    // 허용되어있으면 loadUI실행
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
    
    func preparePlayer(){   //재생할 파일의 url과 볼륨등을 설정할 수 있음
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        do{audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)}
        catch{
            print("asdfasdf")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.volume = 10.0
    }

    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        /*
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRatePerChannelKey : 16
        ]*/

        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatULaw),
            AVSampleRateKey: 44100,
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        audioRecorder.stop()
        audioRecorder = nil
        print(audioFilename)
        
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
