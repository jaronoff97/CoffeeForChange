//
//  CCMenuTableViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit

class CCMenuTableViewController: UITableViewController {
    var items: [FirebaseItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here for menu delegate")
        DataInstance.sharedInstance.setDelegate(self, instance: .menu)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func newItem(_ sender: AnyObject) {
        let ac = UIAlertController(title: "New Item", message: "Make new menu item", preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = "Item Name"
        }
        ac.addTextField { (textfield) in
            textfield.placeholder = "Item Price"
        }
        ac.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            print("Done")
            let newItem = Menu(price: Double(ac.textFields![1].text!)!, name: ac.textFields![0].text!, id: UUID().uuidString)
            DataInstance.sharedInstance.menuRef.child(newItem.id).setValue(newItem.toJSON())
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel")
        }))
        self.present(ac, animated: true) { 
            print("Finished")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

extension CCMenuTableViewController: FirebaseTableDelegate{
    func reloadData() {
        self.tableView.reloadData()
    }
}
extension CCMenuTableViewController{
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel!.text = self.items[(indexPath as NSIndexPath).row].name
     // Configure the cell...
     
     return cell
     }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = items[(indexPath as NSIndexPath).row] as! Menu
        let ac = UIAlertController(title: "What do you want to do?", message: "name: \(item.name) \n price: \(item.price)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
        }))
        ac.addAction(UIAlertAction(title: "Change", style: .default, handler: { (action) in
            
            let sub_ac = UIAlertController(title: "Change Item", message: "Change \(item.name)", preferredStyle: .alert)
            sub_ac.addTextField { (textfield) in
                textfield.placeholder = "Item Name"
            }
            sub_ac.addTextField { (textfield) in
                textfield.placeholder = "Item Price"
            }
            sub_ac.addAction(UIAlertAction(title: "Finished", style: .default, handler: { (action) in
                let new_price = sub_ac.textFields![1].text!
                let new_name = sub_ac.textFields![0].text!
                item.price = (new_price == "" ? item.price : Double(new_price)!)
                item.name = (new_name == "" ? item.name : new_name)
                DataInstance.sharedInstance.menuRef.child(item.id).updateChildValues(item.toJSON())
            }))
            self.present(sub_ac, animated: true, completion: { 
                print("Finished")
            })
        }))
        
        ac.addAction(UIAlertAction(title: "Delete Item", style: .default, handler: { (action) in
            DataInstance.sharedInstance.menuRef.child(item.id).removeValue()
        }))
        self.present(ac, animated: true) { 
            print("Done")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
