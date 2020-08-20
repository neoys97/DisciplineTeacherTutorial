//
//  Student.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation

class Student: Encodable, Decodable {
    var name: String
    var classGroupID: String? = nil
    var toDoImageURL: String? = nil
    var toDoDesc: String? = nil
    var profilePicURL: String? = nil
    var books: [String] = []
    
    init (name: String) {
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, classGroupID, toDoImageURL, toDoDesc, profilePicURL, books
    }
}
