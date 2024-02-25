//
//  SecondViewController.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//

import UIKit
import CoreData

//MARK: - Protocol
protocol SecondViewControllerDelegate: AnyObject {
    var context: NSManagedObjectContext { get }
    func addTransaction()
}

class SecondViewController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: SecondViewControllerDelegate?
    var chosenCategory: String! = "groceries"
    
    private let textField = UITextField()
    private let categoryButton = UIButton()
    private let addButton = UIButton()
    
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupUI()
    }
    
    //MARK: - UI Setup
    func setupUI() {
        self.title = "Add transaction"
        navigationController?.navigationBar.tintColor = .turquoise
        setupTextField()
        setupCategoryButton()
        setupAddButton()
    }
    
    func setupTextField() {
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
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 20),
        ])
    }
    
    func setupCategoryButton() {
        categoryButton.tintColor = .white
        categoryButton.backgroundColor = .darkGray
        categoryButton.layer.cornerRadius = 0
        categoryButton.layer.borderWidth = 2
        categoryButton.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(categoryButton)
        let actionClosure = { [weak self] (action: UIAction) in
            self!.chosenCategory = action.title
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
        addButton.setTitle("Add", for: .normal)
        addButton.backgroundColor = .turquoise
        addButton.tintColor = .black
    
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Methods for UI Interaction
    @objc func addButtonTapped() {
        let transaction = Transaction(context: delegate!.context)
        guard let number = Double(textField.text ?? "") else {
            //зробити нормальну обробку
            fatalError()
        }
        transaction.bitcoins = -number
        transaction.category = chosenCategory
        transaction.date = Date()
        
        do {
            try delegate!.context.save()
        } catch {
            print("Couldn't save transaction: \(error.localizedDescription)")
        }
        
        do {
            let fetchRequest: NSFetchRequest<Balance> = Balance.fetchRequest()
            if let existingBalance = try delegate!.context.fetch(fetchRequest).first {
                existingBalance.bitcoins -= number
            } else {
                let newBalance = Balance(context: delegate!.context)
                newBalance.bitcoins = number
            }
        } catch {
            
        }
        
        delegate!.addTransaction()
        
        navigationController?.popToRootViewController(animated: true)
    }
    
}

