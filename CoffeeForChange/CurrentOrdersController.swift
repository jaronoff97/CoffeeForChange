//
//  CurrentOrdersViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import Firebase

class CurrentOrdersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var items: [Order] = []
    var firebase_orders: Firebase = Firebase(url:"https://coffeeforchange.firebaseio.com/orders")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData(firebase_orders)
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let tempItem: Order = Order(menu_item: rest.value["menu_item"] as! String, description_of_item: rest.value["description"] as! String, user: rest.value["user"] as! String, id: rest.value["id"] as! String)
                    self.items.append(tempItem)
                    self.tableView.reloadData()
            }
            
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let firebase_to_remove = firebase_orders.childByAppendingPath(items[indexPath.row].id)
            firebase_to_remove.removeValue()
            items.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:OrderTableCell = self.tableView.dequeueReusableCellWithIdentifier("orderCell") as! OrderTableCell
        cell.userLabel?.text = items[indexPath.row].user
        cell.nameLabel?.text = items[indexPath.row].menu_item
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
}

