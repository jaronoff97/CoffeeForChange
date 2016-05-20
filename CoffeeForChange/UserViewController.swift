//
//  UserViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/3/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import EPSignature
import Firebase

class UserViewController: UIViewController, EPSignatureDelegate, UITableViewDelegate, UITableViewDataSource {
    var user: User!
    
    var addedItems: [Menu] = []
    var total: Double = 0.0
    let firebase_ref = Firebase(url:"https://coffeeforchange.firebaseio.com")
    
    enum PayMethod {
        case Cash
        case IA
    }
    
    var current_method: PayMethod = .IA
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    
    @IBOutlet weak var menuTable: UITableView!
    
    @IBOutlet weak var addedItemTable: UITableView!
    
    @IBOutlet var totalAmount: UILabel!
   
    @IBOutlet var signatureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = user.full_name!
        moneyLabel.text = "\(user.first_name!) has $\(user.money!) in their account"
        firebase_ref.authWithCustomToken("FzyJevPNtUWU2rEO2P9ih7dYLLFXc6NlFa014TaN", withCompletionBlock: {error, authData in
            if error != nil {
                print("login failed! \(error)")
            }
            else {
                print("Login succeeded! \(authData)")
            }
        })
        let firebase_menu = firebase_ref.childByAppendingPath("/menu")
        configureData(firebase_menu)
        menuTable.delegate = self
        menuTable.dataSource = self
        addedItemTable.delegate = self
        addedItemTable.dataSource = self
        
        self.menuTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.addedItemTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTotal(){
        total = 0.0
        addedItems.forEach( { (let menuItem: Menu) -> () in
                total+=menuItem.price
            })

        totalAmount.text="Total: \(String(total))"
    }
    func openSignatureController(){
        let alertController = UIAlertController(title: "Pay", message: "How do you want to pay?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "IA", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            self.current_method = .IA
            let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
            signatureVC.subtitleText = "I agree to the terms and conditions"
            signatureVC.title = self.user.full_name!
            let nav = UINavigationController(rootViewController: signatureVC)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                print("completed")
            })
        }))
        alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
            self.current_method = .Cash
            self.finishPay(nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,handler: { (action:UIAlertAction) -> Void in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    @IBAction func openSigMenu(sender: UIButton) {
        
        if(total>user.money!){
            let alertController = UIAlertController(title: "Warning", message: "The order you have submitted is greater than the funds in your account", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Add funds ($10) to your account", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                if(self.user.total_money<10){
                    self.user.total_money!+=10.0
                    self.user.money!+=10.0
                }
                else {
                    self.user.total_money!+=self.total
                    self.user.money!+=self.total
                    
                }
                self.openSignatureController()
            }))
            alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
                self.current_method = .Cash
                self.finishPay(nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,handler: { (action:UIAlertAction) -> Void in

            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            openSignatureController()
        }
                //self.navigationController?.pushViewController(signatureVC, animated: true)
        //presentViewController(signatureVC, animated: true, completion:{ () -> Void in print("completed")})
    }
    func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
        print("User canceled")
    }
    func finishPay(sig: UIImage?){
        let firebase_orders = firebase_ref.childByAppendingPath("/orders")
        let firebase_user = firebase_ref.childByAppendingPath("/users/\(user.user_id!)")
        addedItems.forEach({ (let menuItem: Menu) -> () in
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let now = dateFormatter.stringFromDate(NSDate())
            
            var tempOrder = ["menu_item": menuItem.name, "user":user.full_name!, "description":"", "id":NSUUID().UUIDString, "timestamp":now, "price":String(menuItem.price), "userid":user.user_id!, "pay_with_IA":String(current_method.hashValue != 0)]
            
            if let final_image = sig{
                let imageData: NSData = UIImageJPEGRepresentation(final_image, 0.1)!
                let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                tempOrder.updateValue(base64String as String, forKey: "signature")
            }
            else{
                tempOrder.updateValue("", forKey: "signature")
            }
            let order_ref = firebase_orders.childByAppendingPath(tempOrder["id"])
            order_ref.setValue(tempOrder)
            
            let firebase_user_orders = firebase_user.childByAppendingPath("/all_orders/\(tempOrder["id"]!)")
            firebase_user_orders.updateChildValues(tempOrder)
            
        })
        self.navigationController?.popToRootViewControllerAnimated(true)

    }
    func epSignature(_: EPSignatureViewController, didSigned signatureImage : UIImage, boundingRect: CGRect) {
        signatureImageView.image = signatureImage
        let firebase_users = firebase_ref.childByAppendingPath("/users")
        let usersRef = firebase_users.childByAppendingPath("\(user.user_id!)")
        let final_amount =  user.money!-total
        let updateData = ["money_left":final_amount,"total_money":user.total_money!]
        usersRef.updateChildValues(updateData)

        finishPay(signatureImage)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == menuTable){
            return self.items.count;
        }
        else{
            return self.addedItems.count;
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == menuTable){
            let menuCell:MenuTableCell = self.menuTable.dequeueReusableCellWithIdentifier("itemCell") as! MenuTableCell
            
            menuCell.nameLabel?.text = self.items[indexPath.row].name
            menuCell.priceLabel?.text = String(self.items[indexPath.row].price)
            
            return menuCell
        }
        else{
            let menuCell:MenuTableCell = self.addedItemTable.dequeueReusableCellWithIdentifier("addedItemCell") as! MenuTableCell
            
            
            menuCell.nameLabel?.text = self.addedItems[indexPath.row].name
            menuCell.priceLabel?.text = String(self.addedItems[indexPath.row].price)
            
            return menuCell
        }
       
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(tableView == menuTable){
            return false
        }
        else{
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == addedItemTable && editingStyle == UITableViewCellEditingStyle.Delete) {
            addedItems.removeAtIndex(indexPath.row)
            addedItemTable.reloadData()
            calculateTotal()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if(tableView == menuTable){
            addedItems.append(items[indexPath.row])
            calculateTotal()
            menuTable.deselectRowAtIndexPath(indexPath, animated: true)
            addedItemTable.reloadData()
        }
        else{
            addedItemTable.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


    
}

