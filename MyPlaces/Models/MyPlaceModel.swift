//
//  MyPlaceModel.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import RealmSwift

@objcMembers
class MyPlace: Object {
    
     dynamic var name = ""
     dynamic var location: String?
     dynamic var comment: String?
     dynamic var imageData: Data?
    
    convenience init(name: String, location: String?, comment: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.comment = comment
        self.imageData = imageData
    }
}
