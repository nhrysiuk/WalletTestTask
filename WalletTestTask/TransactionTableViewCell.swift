//
//  TransactionTableViewCell.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    //MARK: - Identifier and properties
    static let identifier = "TransactionCell"
    
    func configure(with: Transaction?) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
