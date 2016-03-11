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
    var total: Double = 0.0
    var items: [Menu] = []
    var addedItems: [Menu] = []
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    
    @IBOutlet var menuTable: UITableView!
    
    @IBOutlet var addedItemTable: UITableView!
    
    @IBOutlet var totalAmount: UILabel!
   
    @IBOutlet var signatureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = user.full_name!
        moneyLabel.text = "\(user.first_name!) has $\(user.money!) in their account"
        let firebase_users = Firebase(url:"https://coffeeforchange.firebaseio.com/menu")
        configureData(firebase_users)
        
        self.menuTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        self.addedItemTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "addedItemCell")
        // Do any additional setup after loading the view, typically from a nib.
    }
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.observeSingleEventOfType(.Value, withBlock: { snapshot in
            //print(snapshot)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let secondEnum = rest.children
                while let nextLevel = secondEnum.nextObject() as? FDataSnapshot{
                    print(nextLevel)
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
    
    /*func calculateTotal(){
        let coffeeInt = Double(coffeeAmount.text!)!
        let latteInt = Double(latteAmount.text!)!
        let teaInt = Double(teaAmount.text!)!
        total = (coffeeInt*1.5)+(latteInt*2)+(teaInt*1)
        totalAmount.text="Total: \(String(total))"
    }*/
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
    
    func epSignature(_: EPSignatureViewController, didSigned signatureImage : UIImage, boundingRect: CGRect) {
        signatureImageView.image = signatureImage
        let firebase_ref = Firebase(url:"https://coffeeforchange.firebaseio.com/users")
        let usersRef = firebase_ref.childByAppendingPath("\(user.user_id!)")
        let final_amount =  user.money!-total
        let updateData = ["money_left":final_amount,"total_money":user.total_money!]
        usersRef.updateChildValues(updateData)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let menuCell:UITableViewCell = self.menuTable.dequeueReusableCellWithIdentifier("itemCell")! as UITableViewCell
        
        menuCell.textLabel?.text = self.items[indexPath.row].name
        
        return menuCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }


    
}

