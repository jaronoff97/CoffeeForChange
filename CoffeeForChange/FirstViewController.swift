//
//  FirstViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    var searchController: UISearchController!
    
    let firebase_users = Firebase(url:"https://coffeeforchange.firebaseio.com/users")
    var users = [User]()
    var filteredUsers = [User]()
    var shouldShowSearchResults = false
    var userToPass: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        firebase_users.authWithCustomToken("FzyJevPNtUWU2rEO2P9ih7dYLLFXc6NlFa014TaN", withCompletionBlock: {error, authData in
            if error != nil {
                print("login failed! \(error)")
            }
            else {
                print("Login succeeded! \(authData)")
            }
        })
        configureData(firebase_users)
        configureSearchController()        // Get the data on a post that has changed
        firebase_users.observeEventType(.ChildChanged, withBlock: { snapshot in
            let newUser = self.makeUserFromData(snapshot)
            self.users.removeAtIndex(self.indexOfUser(newUser))
            self.users.append(newUser)
            self.users.sortInPlace({$0.last_name < $1.last_name})
            self.tableView.reloadData()
        })
    }
    func configureData(firebase: Firebase) {
        // Attach a closure to read the data at our posts reference
        firebase.queryOrderedByChild("last").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                self.users.append(self.makeUserFromData(rest))
                self.tableView.reloadData()
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })

    }
    func indexOfUser(tempUser: User) -> Int {
        var toReturn = -1
        
        for i in 0 ..< users.count{
            if(users[i].user_id == tempUser.user_id){
                toReturn = i
            }
        }
        return toReturn
    }
    func makeUserFromData(rest: FDataSnapshot) -> User {
        let tempUser: User = User()
        if let temp_id = rest.value["id"] as! String?{
            tempUser.id = temp_id
        }
        if let temp_First = rest.value["first"] as! String?{
            tempUser.first_name = temp_First
        }
        if let temp_uid = rest.value["user_id"] as! String?{
            tempUser.user_id = temp_uid
        }
        if let temp_Last = rest.value["last"] as! String?{
            tempUser.last_name = temp_Last
        }
        if let temp_money = rest.value["money_left"] as! Double?{
            tempUser.money = temp_money
        }
        if let temp_money = rest.value["total_money"] as! Double?{
            tempUser.total_money = temp_money
        }
        if let temp_year = (rest.value["year"] as! Int?){
            tempUser.year = temp_year
        }
        tempUser.full_name="\(tempUser.first_name!) \(tempUser.last_name!)"
        return tempUser
    }
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