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
    
    var transaction: Transaction?
    private let dateLabel = UILabel()
    private let bitcoinsLabel = UILabel()
    private let categoryLabel = UILabel()
    
    //MARK: - Configuration
    func configure(with transaction: Transaction?) {
        self.transaction = transaction
        setupCategoryLabel()
        setupDateLabel()
        setupBitcoinsLabel()
    }
    
    func setupCategoryLabel() {
        contentView.addSubview(categoryLabel)
        
        categoryLabel.text = "restaurant"
        categoryLabel.font = .systemFont(ofSize: 23, weight: .bold)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }

    func setupDateLabel() {
        contentView.addSubview(dateLabel)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let date = dateFormatter.string(from: Date())
        dateLabel.text = date
        dateLabel.font = .systemFont(ofSize: 18, weight: .regular)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }
    
    func setupBitcoinsLabel() {
        contentView.addSubview(bitcoinsLabel)
        
        bitcoinsLabel.text = "- 0.35 ₿"
        bitcoinsLabel.font = .systemFont(ofSize: 21, weight: .bold)
        
        bitcoinsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bitcoinsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bitcoinsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
