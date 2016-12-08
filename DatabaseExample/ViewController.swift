//
//  ViewController.swift
//  DatabaseExample
//
//  Created by Russell Gordon on 11/8/16.
//  Copyright © 2016 Russell Gordon. All rights reserved.
//

import UIKit

struct Contact {
    var name: String
    var address: String
    var phone: String
    
    init(name: String, address: String, phone: String) {
        self.name = name
        self.address = address
        self.phone = phone
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonPrior: UIButton!
    
    var contactArray = [Contact]()
    var contactArrayIndex = 0
    
    // Object to store reference to DB
    var contactDB : FMDatabase?
    
    // Object to store results retreived from DB
    var results : FMResultSet?
    
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
            if let contactDB = FMDatabase(path: databasePath as String) {
                
                // Try to open the empty database and create the table structure required
                if contactDB.open() {
                    
                    // Define the SQL statement to be run
                    let SQL = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                    
                    // Attempt to run the SQL statement
                    if !contactDB.executeStatements(SQL) {
                        print("Error: \(contactDB.lastErrorMessage())")
                    }
                    
                    // Close the database connection
                    contactDB.close()
                    
                } else {
                    
                    // We couldn't open the database, so throw an error
                    print("Error: \(contactDB.lastErrorMessage())")
                    
                }
                
            }
            
        } else {
            print("Error: Could not create DB.")
        }
        
    }
    
    
    @IBAction func saveData(_ sender: Any) {
        
        // Establish path to database through FMDatabase wrapper
        if let contactDB = FMDatabase(path: databasePath as String) {
            
            // We know database should exist now (since viewDidLoad runs at startup)
            // Now, open the database and insert data from the view (the user interface)
            if contactDB.open() {
                
                // Get data from the form fields on the view (user interface)
                guard let nameValue : String = textFieldName.text else {
                    labelStatus.text = "Hey, we need a name here."
                    return
                }
                guard let addressValue : String = textFieldAddress.text else {
                    labelStatus.text = "Hey, we need an address!"
                    return
                }
                guard let phoneValue : String = textFieldPhone.text else {
                    labelStatus.text = "Please provide a phone number."
                    return
                }
                
                // Create SQL statement to insert data
                let SQL = "INSERT INTO CONTACTS (name, address, phone) VALUES ('\(nameValue)', '\(addressValue)', '\(phoneValue)')"
                
                // Try to run the statement
                let result = contactDB.executeUpdate(SQL, withArgumentsIn: nil)
                
                // Clear the array with contacts as we have a new one
                
                contactArray = [Contact]()
                
                // See what happened and react accordingly
                if !result {
                    labelStatus.text = "Failed to add contact"
                } else {
                    labelStatus.text = "Contact added"
                    
                    // Clear out the form fields
                    resetFields()
                }
                
            }
            
        } else {
            
            // We couldn't open the database, so throw an error
            print("Error: Could not save data to database.")
            
        }
        
    }
    
    @IBAction func findContact(_ sender: Any) {
        
        // Establish path to database through FMDatabase wrapper
        if let contactDB = FMDatabase(path: databasePath as String) {
            
            // We know database should exist now (since viewDidLoad runs at startup)
            // Now, open the database and insert data from the view (the user interface)
            if contactDB.open() {
                
                // Get form field value
                guard let searchString : String = textFieldSearch.text else {
                    labelStatus.text = "Please provide search data."
                    return
                }
                
                // Create SQL statement to find data
                let SQL = "SELECT name, address, phone FROM CONTACTS WHERE name LIKE '%\(searchString)%' OR address LIKE '%\(searchString)%' OR phone LIKE '%\(searchString)%'"
                
                // Run query
                do {
                    
                    // Try to run the query
                    results = try contactDB.executeQuery(SQL, values: nil)
                    
                    // We know database should exist now (since viewDidLoad runs at startup)
                    // Now, open the database and select data using value given for name in the view (user interface)
                    if results?.next() == true {    // Something was found for this query
                        
                        displayResult()
                        
                    } else {
                        
                        // Nothing was found for this query
                        labelStatus.text = "Record not found"
                        resetFields()
                    }
                    
                    
                } catch {
                    
                    // Query did not run, so report an error
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                
            }
            
        } else {
            
            // Database could not be opened, report an error
            print("Error: Database could not be opened.")
            
        }
        
    }
    
    @IBAction func findOnPartialSearchString(_ sender: Any) {
        
        // Invoke the findContact method.
        if let searchString = textFieldSearch.text {
            if searchString == "" {
                resetFields()
                labelStatus.text = ""
                buttonNext.isEnabled = false
                buttonPrior.isEnabled = false
            } else {
                findContact(sender)
            }
        }
        
    }
    
    func resetFields() {
        textFieldName.text = ""
        textFieldAddress.text = ""
        textFieldPhone.text = ""
    }
    
    @IBAction func showNextResult(_ sender: Any) {
        
        contactArrayIndex += 1
        displayResult()
        if (contactArrayIndex != 0)
        {
        buttonPrior.isEnabled = true
        }
    }
    
    @IBAction func showPreviousResult(_ sender: UIButton) {
            contactArrayIndex -= 1
            displayPreviousResult()
            buttonNext.isEnabled = true
        if (contactArrayIndex < 5)
        {
            buttonNext.isEnabled = true
        }
    }
    
    func displayPreviousResult() {
        
        if (contactArray.count > contactArrayIndex)
        {
            textFieldName.text = contactArray[contactArrayIndex].name
            textFieldAddress.text = contactArray[contactArrayIndex].address
            textFieldPhone.text = contactArray[contactArrayIndex].phone
            labelStatus.text = "Record found!"
        }
        if (contactArrayIndex == 0)
        {
            buttonPrior.isEnabled = false
        }
    }
    
    func displayResult() {
        
        if results?.hasAnotherRow() == true {
            
            guard let nameValue : String = results?.string(forColumn: "name") else {
                print("Nil value returned from query for the address, that's odd.")
                return
            }
            guard let addressValue : String = results?.string(forColumn: "address") else {
                print("Nil value returned from query for the address, that's odd.")
                return
            }
            guard let phoneValue : String = results?.string(forColumn: "phone") else {
                print("Nil value returned from query for the phone number, that's odd.")
                return
            }
            
            contactArray.append(Contact(name: nameValue, address: addressValue, phone: phoneValue))
            
            // Load the results in the view (user interface)
            textFieldName.text = nameValue
            textFieldAddress.text = addressValue
            textFieldPhone.text = phoneValue
            labelStatus.text = "Record found!"
            
            // Enable the next result button if there is another result
            if results?.next() == true {
                if results?.hasAnotherRow() == true {
                    buttonNext.isEnabled = true
                }
            } else {
                buttonNext.isEnabled = false
                // Close the database
                if contactDB?.close() == true {
                    print("DB closed")
                }
            }
            
        } else {
            textFieldName.text = contactArray[contactArrayIndex].name
            textFieldAddress.text = contactArray[contactArrayIndex].address
            textFieldPhone.text = contactArray[contactArrayIndex].phone
            labelStatus.text = "Record found!"
            if (contactArrayIndex == contactArray.count - 1)
            {
                buttonNext.isEnabled = false
            }
        }
        
        print("Another row?")
        print(results?.hasAnotherRow())
        print("contents of next row")
        print(results?.resultDictionary())
    }
}

