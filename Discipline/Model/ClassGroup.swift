//
//  ClassGroup.swift
//  Discipline
//
//  Created by Neo Yi Siang on 5/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation

class ClassGroup: Encodable, Decodable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
}
