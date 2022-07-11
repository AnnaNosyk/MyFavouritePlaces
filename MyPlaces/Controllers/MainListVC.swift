//
//  MainListVC.swift
//  MyPlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import UIKit
import RealmSwift

class MainListVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var sortingButton: UIBarButtonItem!
    
    private let constants = Constants()
    private var myPlaces:  Results<MyPlace>!
    
    // for sorting
    private var ascendingSorting = true
    
    // for search
    private let searchController = UISearchController(searchResultsController: nil)
    //items from search
    private var filteredPlaces: Results<MyPlace>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPlaces = realm.objects(MyPlace.self)
        setupSearchBar()
    }
    
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
       // searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func sorting() {
        //sorting data by date
        if segmentedControl.selectedSegmentIndex == 0 {
            myPlaces = myPlaces.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            //sorting data by name
            myPlaces = myPlaces.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }

    
    @IBAction func sortingItemsSegment(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func sortItemsAction(_ sender: Any) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sortingButton.image = UIImage(systemName: "arrow.down.square")
        } else {
            sortingButton.image = UIImage(systemName: "arrow.up.square")
        }
        
        sorting()
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let detailListVC = segue.source as? DetailListVC else { return }
        
        detailListVC.saveItem()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: MyPlace
            if isFiltering {
                //items from search
                place = filteredPlaces[indexPath.row]
            } else {
                //all items from data base
                place = myPlaces[indexPath.row]
            }
            let detailListVC = segue.destination as! DetailListVC
            detailListVC.currentPlace = place
        }
    }

}




// MARK: -  UITableViewDelegate, UITableViewDataSource

extension MainListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //items from search
        if isFiltering {
            return filteredPlaces.count
        }
        //all items from data base
        return myPlaces.isEmpty ? 0 : myPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainListCell().cellId, for: indexPath) as! MainListCell
        
        var listOfPlaces = MyPlace()
        
        if isFiltering {
            //items from search
            listOfPlaces = filteredPlaces[indexPath.row]
        } else {
            //all items from data base
            listOfPlaces = myPlaces[indexPath.row]
        }
        
        cell.nameOfplace.text = listOfPlaces.name
        cell.locationPlace.text = listOfPlaces.location
        cell.commentLabel.text = listOfPlaces.comment
        cell.imagePlace.image = UIImage(data: listOfPlaces.imageData!)
        cell.imagePlace.layer.cornerRadius = constants.heightForImages / 2
        cell.imagePlace.clipsToBounds = true

        return cell
    }
    
    
    //delete rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
 
    
    //delete rows from tableView and Database
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let place = myPlaces[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
}

//MARK: - UISearchResultsUpdating
extension MainListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // filtering items by seach
    private func filterContentForSearchText(_ searchText: String) {
        
        //by name or by location
        filteredPlaces = myPlaces.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}

