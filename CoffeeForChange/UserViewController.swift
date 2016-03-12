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
    var items: [Menu] = []
    var addedItems: [Menu] = []
    var total: Double = 0.0
    let firebase_ref = Firebase(url:"https://coffeeforchange.firebaseio.com")
    
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
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let secondEnum = rest.children
                while let nextLevel = secondEnum.nextObject() as? FDataSnapshot{
                    let tempItem: Menu = Menu(price: ((nextLevel.value["price"] as! NSNumber).doubleValue as Double?)!, name: nextLevel.value["name"] as! String, id: nextLevel.value["id"] as! String)
                    self.items.append(tempItem)
                    self.menuTable.reloadData()
                }
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
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
            let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
            signatureVC.subtitleText = "I agree to the terms and conditions"
            signatureVC.title = self.user.full_name!
            let nav = UINavigationController(rootViewController: signatureVC)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                print("completed")
            })
        }))
        alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
            self.finishPay()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,handler: { (action:UIAlertAction) -> Void in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    @IBAction func openSigMenu(sender: UIButton) {
        
        if(total>user.money!){
            let alertController = UIAlertController(title: "Warning", message: "The order you have submitted is greater than the funds in your account", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Add funds ($10) to your account", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                self.user.total_money!+=10.0
                self.user.money!+=10.0
                self.openSignatureController()
            }))
            alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.Default,handler: { (action:UIAlertAction) -> Void in
                self.finishPay()
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
    func finishPay(){
        let firebase_orders = firebase_ref.childByAppendingPath("/orders")
        addedItems.forEach({ (let menuItem: Menu) -> () in
            let tempOrder = ["menu_item": menuItem.name, "user":user.full_name!, "description":"", "id":NSUUID().UUIDString]
            let order_ref = firebase_orders.childByAppendingPath(tempOrder["id"])
            order_ref.setValue(tempOrder)
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

        finishPay()
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

