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
import Charts
import QuartzCore

class Newrecord: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    
    
    
    let answer = ["물 흐르는 소리","아이 소리","파열음","빗 소리","끓는 소리","알람","전화벨 소리","청소기","헤어드라이어","고양이 소리"]
    let corlor_set = [0xFF9CBB,0xFF6A89,0xFF9E9B,0xffc000,0xe87100,0x7f654c,0xc5a52,0xff8a19,0x00cdff,0x00ebff]
    let category = ["0","1","2","3","4","5","6","7","8","9"]
    var prob : [Double]!
    let ll = ChartLimitLine(limit: 0.4, label: "")
   
    //TODO : Upload....
    //var prob: [Double]!
    
    //var audioFilename = getDocumentsDirectory().appendingPathComponent("recording.pcm")

    
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    
    @IBAction func Play(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Play"{
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            
            preparePlayer()
            audioPlayer.play()
        }
        else{
            audioPlayer.stop()
            self.audioPlayerDidFinishPlaying(audioPlayer, successfully: true)
            
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
                        let data = response.result.value
                        let jsondata = data as! NSDictionary
                        
                       // self.resultLabel.text = "(\(jsondata["classification"] as! Int))\(self.answer[jsondata["classification"] as! Int])"
                        
                        UIView.transition(with: self.back, duration: 5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.image = UIImage(named: "l\(jsondata["classification"] as! Int)")}, completion: nil)
                        //self.back.image = nil
                        /*UIView.transition(with: self.back, duration: 3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.backgroundColor = self.UIColorFromHex(rgbValue: UInt32(self.corlor_set[jsondata["classification"] as! Int]))})
                        */
                        //self.back.image=UIImage(named: "\(jsondata["classification"] as! Int)")
                        
                        self.prob = jsondata["prob"] as! [Double]
                        debugPrint(self.prob)
                        /*
                        self.setChart(dataPoints: self.category, values: self.prob)
                        
                        self.barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 3.0)
                        */
                        
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
        recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        self.recordButton.tintColor = UIColor.white
        self.playBtn.tintColor = UIColor.white
        self.uploadBtn.tintColor = UIColor.white
        /*
        barChartView.sendSubview(toBack: self.view)
        barChartView.setScaleEnabled(true)
        barChartView.backgroundColor = UIColor.clear
        barChartView.noDataText = ""
        */
        

        
       /* let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "background")//if its in images.xcassets
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)*/
        
        self.back.image = UIImage(named: "background")
        
      
        
        
        
    
        
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
        
        audioPlayer.volume = 1.0
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
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
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
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        barChartView.backgroundColor = UIColor.white
        var dataEntries: [BarChartDataEntry] = []
        
        var counter = 0.0
        var xaxis = 0.0
        for i in 0..<dataPoints.count {
            //let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            //let dataEntry = BarChartDataEntry(x: values[i], y: i)
            //let dataEntry = BarChartDataEntry(value: values[i], xIndex: i as Double)
            counter = values[i]
            xaxis += 1.0
            let dataEntry = BarChartDataEntry(x: xaxis, y: counter)
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "확률")
        //let chartData = BarChartData(xVals: categories, dataSet: chartDataSet)
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartData.barWidth = 0.7
        
        barChartView.data = chartData
        barChartView.drawBordersEnabled = true
        barChartView.borderLineWidth = 1
        barChartView.borderColor = UIColor.black
        self.barChartView.rightAxis.addLimitLine(self.ll)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.chartDescription?.text = ""    //remove Description label
        
        
    }
        
        func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
            let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
            let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
            let blue = CGFloat(rgbValue & 0xFF)/256.0
            
            return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
        }
        
        

}


