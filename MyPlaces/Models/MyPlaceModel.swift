//
//  MyPlaceModel.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import UIKit

struct MyPlace {
    
    var name: String
    var image: String
    var location: String
    var comment: String
    
    
    static let placesNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [MyPlace] {
        
        var myPlaces = [MyPlace]()
        
        for place in placesNames {
            myPlaces.append(MyPlace(name: place, image: place, location: "Wroclaw", comment: "Here nice coffee"))
        }
        return myPlaces
    }
}
