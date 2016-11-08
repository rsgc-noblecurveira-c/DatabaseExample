//
//  ViewController.swift
//  DatabaseExample
//
//  Created by Russell Gordon on 11/8/16.
//  Copyright © 2016 Russell Gordon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    
    // Will save path to database file
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Identify the app's Documents directory and build a path to "contacts.db"
        let fileManager = FileManager.default
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPaths[0]
        databasePath = documentsDirectory.appending("contacts.db") as NSString
        
        // Initialize (create) the database if it doesn't already exist
        if !fileManager.fileExists(atPath: databasePath as String) {
            
            // Create the database
            let contactDB = FMDatabase(path: databasePath as String)
            
            // Check that this worked
            if contactDB == nil {
                print("Error: Could not create DB, details: \(contactDB?.lastErrorMessage())")
            }
            
        }
        
        
    }

    
    @IBAction func saveData(_ sender: Any) {
    }
    
    
    @IBAction func findContact(_ sender: Any) {
    }

}

