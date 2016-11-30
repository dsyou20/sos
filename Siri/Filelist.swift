//
//  Filelist.swift
//  Siri
//
//  Created by JJ on 2016. 11. 28..
//  Copyright © 2016년 Sahand Edrisian. All rights reserved.
//

import UIKit

class Filelist: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listFilesFromDocumentsFolder()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func listFilesFromDocumentsFolder() -> [String]
    {
        var filelist = [String]()
        filelist.append("something")
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "pcm" }
            print("pcm urls:",mp3Files,".pcm")
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            for i in mp3FileNames{
             print("pcm list:",i,".pcm")
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }        /*
        if dirs != nil {
            let dir = dirs![0]//this path upto document directory
            
            //this will give you the path to MyFiles
            let MyFilesPath = getDocumentsDirectory().appendingPathComponent("/Myfiles")
            //let MyFilesPath = FileManager.SearchPathDirectory.DocumentDirectory.stringByAppendingPathComponent("/MyFiles")
            
            
            let fileList = FileManager.contentsOfDirectory(<#T##FileManager#>)
            var count = fileList.count
            for i in 0...count
            {
                var filePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
                filePath = filePath.stringByAppendingPathComponent(fileList[i])
                let properties = [NSURLLocalizedNameKey, NSURLCreationDateKey, NSURLContentModificationDateKey, NSURLLocalizedTypeDescriptionKey]
                var attr = NSFileManager.defaultManager().attributesOfItemAtPath(filePath, error: NSErrorPointer())
            }
            return fileList.filter{ $0.pathExtension == "pdf" }.map{ $0.lastPathComponent } as [String]
        }else{
            let fileList = [""]
            return fileList
        }*/
        
        return filelist
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
