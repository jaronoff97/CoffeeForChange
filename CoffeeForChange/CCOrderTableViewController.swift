//
//  CCOrderTableViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CCOrderTableViewController: UITableViewController {
    var items: [FirebaseItem] = []
    var colors_on = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataInstance.sharedInstance.setDelegate(self, instance: .Order)
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CCOrderTableViewController: FirebaseTableDelegate{
    func reloadData() {
        self.tableView.reloadData()
    }
}
extension CCOrderTableViewController{
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell:OrderTableCell = self.tableView.dequeueReusableCellWithIdentifier("orderCell") as! OrderTableCell
        let order = items[indexPath.row] as! Order
        cell.userLabel?.text = order.user
        cell.nameLabel?.text = order.menu_item
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

    @IBAction func colorButton(sender: AnyObject) {
        colors_on=(!colors_on)
        print("PRESSED: \(colors_on)")
        self.tableView.reloadData()
    }

    func colorForIndex(index: Int) -> UIColor {
        let itemCount = items.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    func removeFromFirebase(index: Int){
        /*let firebase_to_remove = self.firebase_orders.childByAppendingPath(self.items[index].id)
        firebase_to_remove.removeValue()
        self.items.removeAtIndex(index)*/
        tableView.reloadData()
    }
    func refund(index: Int){
        /*let refund_user = Firebase(url: "https://coffeeforchange.firebaseio.com/users/\(self.items[index].userid)")
        print(refund_user)
        refund_user.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let new_money = (snapshot.value["money_left"] as! Double)+self.items[index].price
            refund_user.updateChildValues(["money_left":new_money])
            }, withCancelBlock: { error in
                print(error.description)
        })*/
    }
    func openCancelDialog(index: Int){
        let alertController = UIAlertController(title: "Warning", message: "Do you want to cancel your order", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
            if((self.items[index] as! Order).pay_with_IA==true){
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
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}