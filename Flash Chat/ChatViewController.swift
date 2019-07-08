//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

// in order to use tableView, you have to adopt some protocol
// for UIViewController --> ChatViewController is going to be the delegate of the table view, that means that when some action happens in the table you like a cell got clicked on the table you got swiped, then the one that gets notified the delegate is the chat view control
// for UITableViewDelegate --> the chat controller is going to be responsible for serving up the data that's going to be displayed in the table view
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
        // this method gets called for every single cell in the table view and each time we have a different index path bein passed in here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
            // ->  need to register your custom message cell

            // method 1, this is to check if there is any data present in the viewtable, so, method 2
//        let messageArray = ["First Message", "Second Message", "Third Message"]
//        cell.messageBody.text = messageArray[indexPath.row] // this method got called when it has a table row provide
        
            // method 2 (messageArray has message object, and object has messageBody)
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
            // xcode doesn't know the datatype of email, so we cast it as String
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            // message we sent
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        } else {
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
        // how many cells you want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    

    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
        // if the message label has a lot of content then you should resize the cell to fitr all of that content
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
        // this method get triggered auto whenever the question detects a touch inside that textfield So when ever you click in the textfield this methods is going to trigger and our animation are going to work
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
        // this method doesn't get trigger automatically, you have to call it manaually
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }


    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
            // use child method to create a new child database insdie our main database, and given the name called "Message"
        let messagesDB = Database.database().reference().child("Messages")
    
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
    
            // firebase method, creates a custom random key for our message so our message can be saved under their own unique identifier
            // this is saving our message dictionary inside our messages database under an automatically generated identifier
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfullky!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
                // this closure will get called whenever a new item has been added to our messages database and it return a snapshot of that database
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!

                // create a message object below
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
                // add to message array
            self.messageArray.append(message)
            
                // call configureTableView to reform when there is new message
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            // in order to take the user from the chatViewController to the welcomeViewController (they click logout)
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("error, there was a problem signing out.")
        }
    }
    


}
