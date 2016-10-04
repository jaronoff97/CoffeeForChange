//
//  CCUsersTableViewController.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import UIKit

class CCUsersTableViewController: UITableViewController {
    var searchController = UISearchController(searchResultsController: nil)
    var items: [FirebaseItem] = []
    var filteredUsers = [FirebaseItem]()
    var shouldShowSearchResults = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataInstance.sharedInstance.setDelegate(self, instance: .user)
        self.configureSearchController()
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
extension CCUsersTableViewController: FirebaseTableDelegate{
    func reloadData() {
        self.tableView.reloadData()
    }
}
extension CCUsersTableViewController{
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
extension CCUsersTableViewController{
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if (segue.identifier == "detailTableSegue") {
            // initialize new view controller and cast it as your view controller
            //let viewController = (segue.destinationViewController as! UINavigationController).childViewControllers[0] as! UserViewController
            let viewController = segue.destination as! UserViewController
            self.navigationItem.title = DataInstance.sharedInstance.user!.full_name
            
            // your new view controller should have property that will store passed value
            searchController.isActive = false
            self.present(viewController, animated: true, completion: { 
                
            })
        }
        
    }
}
extension CCUsersTableViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
}
extension CCUsersTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchString = searchController.searchBar.text else {
            return
        }
        // Filter the data array and get only those countries that match the search text.
        filteredUsers = items.filter({ (temp_user) -> Bool in
            let fullUserData: NSString = (temp_user as! User).full_name as NSString
            let dataToReturn = (fullUserData.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            return dataToReturn
        })
        
        // Reload the tableview.
        tableView.reloadData()
    }
    
}
extension CCUsersTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearchResults){
            return self.filteredUsers.count
        }
        else{
            return self.items.count;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "userCell")! as UITableViewCell
        if(shouldShowSearchResults){
            cell.textLabel?.text = (filteredUsers[(indexPath as NSIndexPath).row] as! User).full_name
        }
        else{
            cell.textLabel?.text = (self.items[(indexPath as NSIndexPath).row] as! User).full_name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(shouldShowSearchResults){
            DataInstance.sharedInstance.user = filteredUsers[(indexPath as NSIndexPath).row] as? User
        }
        else{
            DataInstance.sharedInstance.user = self.items[(indexPath as NSIndexPath).row] as? User
        }
        tableView.deselectRow(at: indexPath, animated: true)
        print("test!!!")
        print(DataInstance.sharedInstance.user)
        //self.performSegueWithIdentifier("detailTableSegue", sender: self)
    }
}



