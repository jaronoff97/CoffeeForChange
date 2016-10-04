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

class UserViewController: UIViewController  {
    var user: User!
    
    var addedItems: [Menu] = []
    var items: [Menu] = []
    var total: Double = 0.0
    
    enum PayMethod {
        case cash
        case ia
    }
    
    var current_method: PayMethod = .ia
    let firebase_ref = DataInstance.sharedInstance.rootRef
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    
    
    @IBOutlet weak var menuTable: UITableView!
    
    @IBOutlet weak var addedItemTable: UITableView!
    
    @IBOutlet var totalAmount: UILabel!
   
    @IBOutlet var signatureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(DataInstance.sharedInstance.user != nil, "User is nil!")
        user = DataInstance.sharedInstance.user!
        nameLabel.text = user.full_name
        moneyLabel.text = "\(user.name) has $\(user.money) in their account"
        
        menuTable.delegate = self
        menuTable.dataSource = self
        addedItemTable.delegate = self
        addedItemTable.dataSource = self
        items = (DataInstance.sharedInstance.getData(forInstance: .menu) as! MenuInstance).items.map({ (item) -> Menu in
            return (item as! Menu)
        })
        
        self.menuTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.addedItemTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTotal(){
        total = 0.0
        
        addedItems.forEach( { (menuItem: Menu) -> () in
                total+=menuItem.price
            })

        totalAmount.text="Total: \(String(total))"
    }
    func openSignatureController(){
        let alertController = UIAlertController(title: "Pay", message: "How do you want to pay?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "IA", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            self.current_method = .ia
            let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
            signatureVC.subtitleText = "I agree to the terms and conditions"
            signatureVC.title = self.user.full_name
            let nav = UINavigationController(rootViewController: signatureVC)
            self.present(nav, animated: true, completion: { () -> Void in
                print("completed")
            })
        }))
        alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction) -> Void in
            self.current_method = .cash
            self.finishPay(nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: { (action:UIAlertAction) -> Void in
            
        }))
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    @IBAction func openSigMenu(_ sender: UIButton) {
        
        if(total>user.money){
            let alertController = UIAlertController(title: "Warning", message: "The order you have submitted is greater than the funds in your account", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Add funds ($10) to your account", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
                if(self.user.total_money<10){
                    self.user.total_money+=10.0
                    self.user.money+=10.0
                }
                else {
                    self.user.total_money+=self.total
                    self.user.money+=self.total
                    
                }
                self.openSignatureController()
            }))
            alertController.addAction(UIAlertAction(title: "Cash", style: UIAlertActionStyle.default,handler: { (action:UIAlertAction) -> Void in
                self.current_method = .cash
                self.finishPay(nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: { (action:UIAlertAction) -> Void in

            }))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            openSignatureController()
        }
                //self.navigationController?.pushViewController(signatureVC, animated: true)
        //presentViewController(signatureVC, animated: true, completion:{ () -> Void in print("completed")})
    }
    func finishPay(_ sig: UIImage?, completion: (_ ref: FIRDatabaseReference)->Void={ref in return}){
        
        let firebase_orders = firebase_ref.child("/orders")
        let firebase_user = firebase_ref.child("/users/\(user.user_id)")
        completion(firebase_user)
        addedItems.forEach({ (menuItem: Menu) -> () in
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let now = (dateFormatter.string(from: Date()))
            
            var tempOrder = Order(menu_item: menuItem.name, description_of_item: "", user: user.full_name, id: UUID().uuidString, timestamp: now, price: menuItem.price, userid: user.user_id, pay_with_IA: current_method.hashValue != 0, signature: nil)
            if let final_image = sig{
                let imageData: Data = UIImageJPEGRepresentation(final_image, 0.1)!
                let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
                tempOrder.signature = base64String
                    //.updateValue(base64String as String, forKey: "signature")
            }
            else{
                tempOrder.signature=""
            }
            let order_ref = firebase_orders.child(tempOrder.id)
            order_ref.setValue(tempOrder.toJSON())
            
            let firebase_user_orders = firebase_user.child("/all_orders/\(tempOrder.id)")
            firebase_user_orders.updateChildValues(tempOrder.toJSON())
            
        })
        self.navigationController?.popToRootViewController(animated: true)

    }
}
extension UserViewController: UITableViewDelegate, UITableViewDataSource{
    // MARK: - Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == menuTable){
            return self.items.count;
        }
        else{
            return self.addedItems.count;
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == menuTable){
            let menuCell:MenuTableCell = self.menuTable.dequeueReusableCell(withIdentifier: "itemCell") as! MenuTableCell
            
            menuCell.nameLabel?.text = self.items[(indexPath as NSIndexPath).row].name
            menuCell.priceLabel?.text = String(self.items[(indexPath as NSIndexPath).row].price)
            
            return menuCell
        }
        else{
            let menuCell:MenuTableCell = self.addedItemTable.dequeueReusableCell(withIdentifier: "addedItemCell") as! MenuTableCell
            
            
            menuCell.nameLabel?.text = self.addedItems[(indexPath as NSIndexPath).row].name
            menuCell.priceLabel?.text = String(self.addedItems[(indexPath as NSIndexPath).row].price)
            
            return menuCell
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(tableView == menuTable){
            return false
        }
        else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (tableView == addedItemTable && editingStyle == UITableViewCellEditingStyle.delete) {
            addedItems.remove(at: (indexPath as NSIndexPath).row)
            addedItemTable.reloadData()
            calculateTotal()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView == menuTable){
            addedItems.append(items[(indexPath as NSIndexPath).row])
            calculateTotal()
            menuTable.deselectRow(at: indexPath, animated: true)
            addedItemTable.reloadData()
        }
        else{
            addedItemTable.deselectRow(at: indexPath, animated: true)
        }
    }
}
extension UserViewController: EPSignatureDelegate{
    @objc(epSignature:didSign:boundingRect:) func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
        signatureImageView.image = signatureImage
        
        
        finishPay(signatureImage) {
            ref in
            let final_amount =  self.user.money-self.total
            let updateData = ["money_left":final_amount,"total_money":self.user.total_money]
            ref.updateChildValues(updateData)
        }
    }
    func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
        print("User canceled")
    }
}

