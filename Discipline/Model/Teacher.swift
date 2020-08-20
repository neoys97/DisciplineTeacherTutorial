//
//  Teacher.swift
//  DisciplineTeacher
//
//  Created by Neo Yi Siang on 7/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation

class Teacher: Encodable, Decodable {
    var name: String
    var profilePicURL: String? = nil

    init (name: String) {
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, profilePicURL
    }
}
