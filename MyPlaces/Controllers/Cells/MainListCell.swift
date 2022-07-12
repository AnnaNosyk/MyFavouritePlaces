//
//  MainListCell.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import UIKit

class MainListCell: UITableViewCell {

    let cellId = "MainListCell"
    @IBOutlet var imagePlace: UIImageView!
    @IBOutlet var nameOfplace: UILabel!
    @IBOutlet var locationPlace: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
}
