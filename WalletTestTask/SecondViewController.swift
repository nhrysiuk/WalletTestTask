//
//  SecondViewController.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//

import UIKit

class SecondViewController: UIViewController {

    private let textField: UITextField = {
        let textField = UITextField()
        let placeholderText = "Enter a number..."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        textField.textColor = .turquoise
        textField.backgroundColor = .darkGray
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.white.cgColor
        
        return textField
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.tintColor = .turquoise
        button.backgroundColor = .darkGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .black
        setupUI()
    }
    
    func setupUI() {
        self.title = "Add transaction"
        navigationController?.navigationBar.tintColor = .turquoise
        setupTextField()
        setupCategoryButton()
        setupAddButton()
    }
    
    // можливо, краще інший елемент
    func setupTextField() {
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 20),
        ])
    }
    
    func setupCategoryButton() {
        view.addSubview(categoryButton)
        let actionClosure = { (action: UIAction) in
            print(action.title)
        }
        var menuChildren: [UIMenuElement] = []
        for category in Category.allCases {
            menuChildren.append(UIAction(title: category.rawValue, handler: actionClosure))
        }
        
        categoryButton.menu = UIMenu(options: .displayInline, children: menuChildren)
        
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.changesSelectionAsPrimaryAction = true
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryButton.topAnchor.constraint(equalTo: textField.bottomAnchor,
                                                constant: 20),
            categoryButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    func setupAddButton() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func addButtonTapped() {
        
    }
    
}

