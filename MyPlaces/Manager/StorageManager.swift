//
//  StorageManager.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 11/07/2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: MyPlace) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: MyPlace) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
