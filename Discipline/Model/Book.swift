//
//  Book.swift
//  Discipline
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation

class Book: Encodable, Decodable {
    var name: String
    var classGroupID: String
    var imageURL: String? = nil
    var bought: Bool = false
    
    init (name: String, classGroupID: String) {
        self.name = name
        self.classGroupID = classGroupID
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, classGroupID, imageURL
    }
}
