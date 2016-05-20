//
//  FirstViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var searchController: UISearchController!
    
    
    
    var filteredUsers = [User]()
    var shouldShowSearchResults = false
    var userToPass: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        configureSearchController()        // Get the data on a post that has changed
        
    }
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchController.searchBar
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "detailTableSegue") {
            // initialize new view controller and cast it as your view controller
            //let viewController = (segue.destinationViewController as! UINavigationController).childViewControllers[0] as! UserViewController
            let viewController = segue.destinationViewController as! UserViewController
            self.navigationItem.title = "Back"

            // your new view controller should have property that will store passed value
            viewController.user = userToPass
            viewController.navigationItem.title = "\(userToPass.full_name!)"
            searchController.active = false
        }
        
    }

}
extension FirstViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }

}
extension FirstViewController: UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredUsers = users.filter({ (temp_user) -> Bool in
            let fullUserData: NSString = temp_user.full_name!
            let dataToReturn = (fullUserData.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
            return dataToReturn
        })
        
        // Reload the tableview.
        tableView.reloadData()
    }

}
extension FirstViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearchResults){
            return self.filteredUsers.count
        }
        else{
            return self.users.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if(shouldShowSearchResults){
            cell.textLabel?.text = filteredUsers[indexPath.row].full_name!
        }
        else{
            cell.textLabel?.text = self.users[indexPath.row].full_name!
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(shouldShowSearchResults){
            userToPass = filteredUsers[indexPath.row]
        }
        else{
            userToPass = users[indexPath.row]
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("detailTableSegue", sender: self)
    }
}

