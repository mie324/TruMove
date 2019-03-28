//
//  SportSearchController.swift
//  groupproject
//
//  Created by Ellen Wang on 2019/3/1.
//  Copyright © 2019 ellen. All rights reserved.
//

import UIKit
import Firebase

class SportSearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var sports: [String] = ["Weightlifting", "Basketball","Boxing"]
    var filteredSports = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        setUpSearchBar()
        
    }
    
    fileprivate func setUpSearchBar(){
        searchController.searchResultsUpdater = self as! UISearchResultsUpdating
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = "Search sports"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true
    }
    
    //MARK: UPDATE SEARCH RESULT
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSports = sports.filter({( sport : String) -> Bool in
            return sport.lowercased().contains(searchText.lowercased())
        })
        
        tableview.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
    
    //MARK: TABLE VIEW SETUP
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredSports.count
        }
        
        return sports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sport: String
        if isFiltering() {
            sport = filteredSports[indexPath.row] + ".png"
        } else {
            sport = sports[indexPath.row] + ".png"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportCell", for: indexPath) as! SportSearchCell
        
        cell.setImage(image: UIImage(named:sport)!)
        
        return cell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMove", sender: self)
    }
}
extension SportSearchController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
}
