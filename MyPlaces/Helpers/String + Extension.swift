//
//  String + Extension.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 15/07/2022.
//

import Foundation
extension String {
    func localized() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
}
