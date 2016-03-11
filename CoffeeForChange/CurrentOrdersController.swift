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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firebase_orders = Firebase(url:"https://coffeeforchange.firebaseio.com/orders")
        configureData(firebase_orders)
        
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "orderCell")
    }
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.observeSingleEventOfType(.Value, withBlock: { snapshot in
            //print(snapshot)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {

                let tempItem: Order = Order(menu_item: rest.value["menu_item"] as! String, description_of_item: rest.value["description"] as! String, user: rest.value["user"] as! String)
                    
                        /*: ((nextLevel.value["price"] as! NSNumber).doubleValue as Double?)!, name: nextLevel.value["name"] as! String, id: nextLevel.value["id"] as! String)*/
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("menuCell")! as UITableViewCell
        
        cell.textLabel?.text = (self.items[indexPath.row].menu_item)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    
}

