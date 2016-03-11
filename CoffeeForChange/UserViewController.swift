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

class UserViewController: UIViewController, EPSignatureDelegate {
    var user: User!
    var total: Double = 0.0
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    @IBOutlet var coffeeAmount: UILabel!
    @IBOutlet var latteAmount: UILabel!
    @IBOutlet var teaAmount: UILabel!
    
    @IBOutlet var coffeeStepper: UIStepper!
    @IBOutlet var latteStepper: UIStepper!
    @IBOutlet var teaStepper: UIStepper!
    
    @IBOutlet var totalAmount: UILabel!
   
    @IBOutlet var signatureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = user.full_name!
        moneyLabel.text = "\(user.first_name!) has $\(user.money!) in their account"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func coffeeStepper(sender: UIStepper) {
        if(Int(sender.value)>=0){
            coffeeAmount.text = Int(sender.value).description
        }
        calculateTotal()
    }
    @IBAction func latteStepper(sender: UIStepper) {
        if(Int(sender.value)>=0){
            latteAmount.text = Int(sender.value).description
        }
        calculateTotal()
    }
    @IBAction func teaStepper(sender: UIStepper) {
        if(Int(sender.value)>=0){
                teaAmount.text = Int(sender.value).description
        }
        calculateTotal()
        
    }
    func calculateTotal(){
        let coffeeInt = Double(coffeeAmount.text!)!
        let latteInt = Double(latteAmount.text!)!
        let teaInt = Double(teaAmount.text!)!
        total = (coffeeInt*1.5)+(latteInt*2)+(teaInt*1)
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
                self.latteStepper.value=0
                self.coffeeStepper.value=0
                self.teaStepper.value=0
                self.coffeeAmount.text = "0"
                self.teaAmount.text = "0"
                self.latteAmount.text = "0"
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

    
}

