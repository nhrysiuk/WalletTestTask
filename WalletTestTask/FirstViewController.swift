//
//  FirstViewController.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//

import UIKit

//🟠 Перший екран має відображати баланс bitcoins ___ Додавання введеного балансу до поточного, запити про кількість рядків
//✅ Поруч із балансом має бути кнопка поповнення балансу
//✅ При натисканні на неї, відображаємо поп-ап з полем введення кількості bitcoins, на яку ми хочемо поповнити наш баланс
//🟥 - later | Змінювати дані в бд + створити сутність для балансу
//✅ Під балансом відображаємо кнопку “Add transaction”🟠, вона має вести на Екран 2.
//🟥 - delegate

//🟥 - later | Нижче відображається список усіх транзакцій (в одному списку як поповнення балансу, так і витрати). Список транзакцій повинен групуватися по днях, від нових до старих. Кожна транзакція повинна відображати: час транзакції, кількість витрачених bitcoins, а також одну з категорій (groceries, taxi, electronics, restaurant, other).
//🟥 - later | Під час відображення використовуємо пагінацію по 20 транзакцій. При скролінгу підвантажуємо наступні 20 і т.д.
//🟠 візуал є, додати фетчинг та обробку json, оновлення раз на годину | Праворуч вгорі відображаємо курс Bitcoin по відношенню до долара. Він повинен оновлюватися кожну сесію, але не частіше ніж раз на годину (за сесію вважаємо запуск та відкриття додатку з бекграунду).
//🟥 - at the end | Уніфіковані кольори для режимів

class FirstViewController: UIViewController {
    
    // MARK: - UI Elements & other variables
    private let bitcoinsBalance: UILabel = {
        let label = UILabel()
        //shadow?
        label.textColor = .white
        label.text = "0 ₿"
        label.font = .systemFont(ofSize: 50, weight: .semibold)
        
        return label
    }()
    
    private let fillUpBalance: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .regular), forImageIn: .normal)
        button.tintColor = .turquoise
        
        return button
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add transaction", for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private let transactionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        return tableView
    }()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        self.title = "Wallet"
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]
        
        let rightBarButtonItem = UIBarButtonItem(customView: createLabelView())
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        setupUI()
    }
    
    // MARK: - Setup UIElements
    func setupUI() {
        setupBitcoinsBalance()
        setupFillUpBalance()
        setupAddTransaction()
        setupTransactionsTableView()
    }
    
    func createLabelView() -> UIView {
        let containerView = UIView()
        
        let label = UILabel()
        label.text = "$51,120.00"
        label.textColor = .white
        
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        return containerView
    }
    
    func setupBitcoinsBalance() {
        view.addSubview(bitcoinsBalance)
        bitcoinsBalance.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bitcoinsBalance.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bitcoinsBalance.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: 10),
        ])
    }
    
    func setupFillUpBalance() {
        fillUpBalance.addTarget(self, action: #selector(fillUpButtonTapped), for: .touchUpInside)
        view.addSubview(fillUpBalance)
        fillUpBalance.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fillUpBalance.centerYAnchor.constraint(equalTo: bitcoinsBalance.centerYAnchor),
            fillUpBalance.leadingAnchor.constraint(equalTo: bitcoinsBalance.trailingAnchor,
                                                   constant: 10),
        ])
    }
    
    func setupAddTransaction() {
        addTransactionButton.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        view.addSubview(addTransactionButton)
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTransactionButton.topAnchor.constraint(equalTo: bitcoinsBalance.bottomAnchor,
                                                constant: 5),
        ])
    }
    
    func setupTransactionsTableView() {
        self.transactionsTableView.delegate = self
        self.transactionsTableView.dataSource = self
        
        view.addSubview(transactionsTableView)
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            transactionsTableView.topAnchor.constraint(equalTo: addTransactionButton.bottomAnchor,
                                                       constant: 15),
            transactionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            transactionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc func fillUpButtonTapped() {
        //TODO: design
        let fillUpAlertController = UIAlertController(title: "Add bitcoins 🪙", message: "Write an amount of bitcoins to add: ", preferredStyle: .alert)
        // TODO: make ui prettier
        fillUpAlertController.addTextField { textField in
            textField.placeholder = "Enter an amount of bitcoins..."
            textField.keyboardType = .decimalPad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak fillUpAlertController] _ in
            if let textField = fillUpAlertController?.textFields?.first,
               let enteredNumber = textField.text {
                // TODO: fix + only numbers available
                self?.bitcoinsBalance.text = "\(enteredNumber) ₿"
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        fillUpAlertController.addAction(saveAction)
        fillUpAlertController.addAction(cancelAction)
        
        present(fillUpAlertController, animated: true, completion: nil)
    }
    
    @objc func addTransactionButtonTapped() {
        let secondVC = SecondViewController()
        
        navigationController?.pushViewController(secondVC, animated: true)
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    //TODO: add db
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    //TODO: add db
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else {
            fatalError("oops")
        }
        
        cell.configure(with: nil)
        
        return cell
    }
    
    //TODO: count number of sections (days)
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension UIColor {
    static var turquoise: UIColor {
          return UIColor(red: 104/255, green: 222/255, blue: 228/255, alpha: 1.0)
      }
}
