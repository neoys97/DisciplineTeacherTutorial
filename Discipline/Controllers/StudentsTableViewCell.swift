//
//  StudentsTableViewCell.swift
//  DisciplineTeacher
//
//  Created by Neo Yi Siang on 17/8/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class StudentsTableViewCell: UITableViewCell {

    @IBOutlet weak var studentName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
