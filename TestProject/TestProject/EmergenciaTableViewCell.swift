//
//  EmergenciaTableViewCell.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 09/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit

class EmergenciaTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPick: UIImageView!
    
    @IBOutlet weak var nome: UILabel!
    
    @IBOutlet weak var numero: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
