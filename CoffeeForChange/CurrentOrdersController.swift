//
//  CurrentOrdersViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

class CurrentOrdersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    var items: [Order] = []
    var colors_on = false
    var firebase_orders: Firebase = Firebase(url:"https://coffeeforchange.firebaseio.com/orders")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase_orders.authWithCustomToken("FzyJevPNtUWU2rEO2P9ih7dYLLFXc6NlFa014TaN", withCompletionBlock: {error, authData in
            if error != nil {
                print("login failed! \(error)")
            }
            else {
                print("Login succeeded! \(authData)")
            }
        })
        configureData(firebase_orders)
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.observeEventType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let results = self.items.filter { $0.id == (rest.value["id"] as! String)}
                let exists = results.isEmpty == false
                if exists == true{
                    continue
                }
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let date = dateFormatter.dateFromString(rest.value["timestamp"] as! String)
                var sig = ""
                if let signature:String = rest.value["signature"] as? String{
                    sig=signature
                }
                let tempItem: Order = Order(menu_item: rest.value["menu_item"] as! String,
                    description_of_item: rest.value["description"] as! String,
                    user:rest.value["user"] as! String,
                    id: rest.value["id"] as! String,
                    timestamp: date!,
                    price: Double(rest.value["price"] as! String)!,
                    userid: rest.value["userid"] as! String,
                    pay_with_IA: (rest.value["pay_with_IA"] as! String).toBool()!,
                    signature: self.makeImageFromString(sig)
                )
                self.items.append(tempItem)
                self.tableView.reloadData()
                
            }
            self.items.sortInPlace({ $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedDescending })
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = items.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    func removeFromFirebase(index: Int){
        let firebase_to_remove = self.firebase_orders.childByAppendingPath(self.items[index].id)
        firebase_to_remove.removeValue()
        self.items.removeAtIndex(index)
        tableView.reloadData()
    }
    func refund(index: Int){
        let refund_user = Firebase(url: "https://coffeeforchange.firebaseio.com/users/\(self.items[index].userid)")
        print(refund_user)
        refund_user.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let new_money = (snapshot.value["money_left"] as! Double)+self.items[index].price
            refund_user.updateChildValues(["money_left":new_money])
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    func openCancelDialog(index: Int){
        let alertController = UIAlertController(title: "Warning", message: "Do you want to cancel your order", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            if(self.items[index].pay_with_IA==true){
                self.refund(index)
            }
            self.removeFromFirebase(index)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel,handler: { (action:UIAlertAction) -> Void in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func showSignature(image: UIImage){
        let alertController = UIAlertController(title: "Signature", message: "User's Signature", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "title", style: .Default, handler: nil)
        action.setValue(image, forKey: "image")
        alertController.addAction(action)
        alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Cancel,handler: { (action:UIAlertAction) -> Void in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:OrderTableCell = self.tableView.dequeueReusableCellWithIdentifier("orderCell") as! OrderTableCell
        cell.userLabel?.text = items[indexPath.row].user
        cell.nameLabel?.text = items[indexPath.row].menu_item
        cell.leftButtons = [MGSwipeButton(title: "Done", icon: UIImage(named:"check.png"), backgroundColor: UIColor.greenColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.removeFromFirebase(indexPath.row)
            return true
        })]
        cell.rightButtons = [MGSwipeButton(title: "Delete", icon: UIImage(named:"check.png"), backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.openCancelDialog(indexPath.row)
            return true
        })]
        cell.leftExpansion.fillOnTrigger = true
        cell.leftExpansion.buttonIndex = 0
        cell.leftSwipeSettings.transition = MGSwipeTransition.Drag
        
        cell.rightExpansion.fillOnTrigger = true
        cell.rightExpansion.buttonIndex = 0
        cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
        
        if(colors_on==true){
                cell.backgroundColor = colorForIndex(indexPath.row)
        }
        else{
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    func makeImageFromString(imageSnap: String) -> UIImage?{
        if(imageSnap==""){
            return nil
        }else{
            
            let base64String = imageSnap
            let imageData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let decodedImage = UIImage(data:imageData!)
            return decodedImage
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //showSignature(self.items[indexPath.row].signature)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    @IBAction func colorButton(sender: AnyObject) {
        colors_on=(!colors_on)
        print("PRESSED: \(colors_on)")
        self.tableView.reloadData()
    }
    
}

