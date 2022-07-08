//
//  ViewController.swift
//  MyPlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import UIKit

class MainListVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let constants = Constants()
    let myPlaces = MyPlace.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


}


extension MainListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainListCell().cellId, for: indexPath) as! MainListCell
        cell.nameOfplace.text = myPlaces[indexPath.row].name
        cell.locationPlace.text = myPlaces[indexPath.row].location
        cell.commentLabel.text = myPlaces[indexPath.row].comment
        cell.imagePlace.image = UIImage(named: myPlaces[indexPath.row].image)
        cell.imagePlace.layer.cornerRadius = constants.heightForImages / 2
        cell.imagePlace.clipsToBounds = true
                                        
        return cell
    }
        
    
}

