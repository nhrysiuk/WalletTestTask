//
//  FirstViewController.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//

import UIKit
import CoreData

// fill up 0 !!!!!!!
//✅ запити про кількість рядків | Перший екран має відображати баланс bitcoins ___ Додавання введеного балансу до поточного
//✅ Поруч із балансом має бути кнопка поповнення балансу
//✅ При натисканні на неї, відображаємо поп-ап з полем введення кількості bitcoins, на яку ми хочемо поповнити наш баланс
//✅ - later | Змінювати дані в бд + створити сутність для балансу
//✅ Під балансом відображаємо кнопку “Add transaction”🟠, вона має вести на Екран 2.
//✅ - delegate

//✅ Нижче відображається список усіх транзакцій (в одному списку як поповнення балансу, так і витрати). Список транзакцій повинен групуватися по днях, від нових до старих. Кожна транзакція повинна відображати: час транзакції, кількість витрачених bitcoins, а також одну з категорій (groceries, taxi, electronics, restaurant, other).
//✅ Під час відображення використовуємо пагінацію по 20 транзакцій. При скролінгу підвантажуємо наступні 20 і т.д.
//🟠 оновлення раз на годину | Праворуч вгорі відображаємо курс Bitcoin по відношенню до долара. Він повинен оновлюватися кожну сесію, але не частіше ніж раз на годину (за сесію вважаємо запуск та відкриття додатку з бекграунду).
//🟥 - at the end | Уніфіковані кольори для режимів Added pagination, created file for additional stuff, made code more readable

class FirstViewController: UIViewController {
    
    // MARK: - UI Elements & other variables
    private let bitcoinsBalance = UILabel()
    private let fillUpBalance = UIButton()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bitcoinsBalance, fillUpBalance])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let addTransactionButton = UIButton()
    private let transactionsTableView = UITableView()
    private var rateLabel = UILabel()
    
    var transactions = [Transaction]()
    var transactionsByDate = [String: [Transaction]]()
    var balance: [Balance]?
    var timeOfLastUpdate: Date?
    var rate: String?
    
    var transactionsPerPage = 10
    var totalTransactionsCount = 0
    var loadedTransactionsCount = 0
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        fetchBalance()
        fetchTransactions()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UIElements
    func setupUI() {
        view.backgroundColor = .black
        self.title = "Wallet"
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]
        
        let rightBarButtonItem = UIBarButtonItem(customView: createLabelView())
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        setupStackView()
        setupAddTransaction()
        setupTransactionsTableView()
    }
    
    func createLabelView() -> UIView {
        rateLabel.textColor = .turquoise
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.addSubview(rateLabel)
        
        NSLayoutConstraint.activate([
            rateLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            rateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            rateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        updateRateLabelIfNeeded()
        
        return containerView
    }
    
    func updateRateLabelIfNeeded() {
        fetchTime()
        
        if timeOfLastUpdate == nil || Date().timeIntervalSince(timeOfLastUpdate!) >= 3600 {
            Task {
                await fetchRateFromAPI()
                DispatchQueue.main.async {
                    let newRate = Rate(context: self.context)
                    newRate.dollars = Double(self.rate!) ?? 0
                    
                    do {
                        try self.context.save()
                    } catch {
                        print("Couldn't save rate: \(error.localizedDescription)")
                    }
                    self.rateLabel.text = "$ \(self.rate ?? "0")"
                }
            }
        } else {
            fetchRateFromCD()
            self.rateLabel.text = "$ \(String(describing: self.rate))"
        }
    }
    
    func fetchRateFromAPI() async {
        rate = await APIProcessor.fetchExchangeRate() ?? "no data"
        
        timeOfLastUpdate = Date()
    }
    
    func setupStackView() {
        bitcoinsBalance.textColor = .white
        bitcoinsBalance.text = "0 ₿"
        bitcoinsBalance.font = .systemFont(ofSize: 50, weight: .semibold)
        bitcoinsBalance.numberOfLines = 0
        fillUpBalance.addTarget(self, action: #selector(fillUpButtonTapped), for: .touchUpInside)
        view.addSubview(stackView)
        
        fillUpBalance.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        fillUpBalance.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .regular), forImageIn: .normal)
        fillUpBalance.tintColor = .turquoise
        
        NSLayoutConstraint.activate([
            fillUpBalance.widthAnchor.constraint(equalToConstant: 30),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupAddTransaction() {
        addTransactionButton.setTitle("Add transaction", for: .normal)
        addTransactionButton.tintColor = .white
        
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
        transactionsTableView.backgroundColor = .darkGray
        transactionsTableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
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
    
    // MARK: - Methods for UI Interaction
    @objc func fillUpButtonTapped() {
        let fillUpAlertController = UIAlertController(title: "Add bitcoins 🪙",
                                                      message: "Write an amount of bitcoins to add: ",
                                                      preferredStyle: .alert)
        fillUpAlertController.addTextField { textField in
            textField.placeholder = "Enter an amount of bitcoins..."
            textField.keyboardType = .decimalPad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak fillUpAlertController] _ in
            guard let self = self else { return }
            
            if let textField = fillUpAlertController?.textFields?.first,
               let enteredNumber = textField.text {
                let number = Double(enteredNumber) ?? 0.0
                do {
                    let fetchRequest: NSFetchRequest<Balance> = Balance.fetchRequest()
                    if let existingBalance = try context.fetch(fetchRequest).first {
                        existingBalance.bitcoins += number
                    } else {
                        let newBalance = Balance(context: context)
                        newBalance.bitcoins = number
                    }
                    
                    let transaction = Transaction(context: self.context)
                    transaction.bitcoins = number
                    transaction.category = "fill up"
                    transaction.date = Date()
                    
                    do {
                        try context.save()
                    } catch {
                        print("Couldn't save transaction: \(error.localizedDescription)")
                    }
                    
                    addTransaction()
                    self.fetchBalance()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        fillUpAlertController.addAction(saveAction)
        fillUpAlertController.addAction(cancelAction)
        
        present(fillUpAlertController, animated: true, completion: nil)
    }
    
    @objc func addTransactionButtonTapped() {
        let secondVC = SecondViewController()
        
        secondVC.delegate = self
        navigationController?.pushViewController(secondVC, animated: true)
    }
}

//MARK: - TableView setup
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsByDate.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(transactionsByDate.keys)[section]
        return transactionsByDate[date]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else {
            fatalError("oops")
        }
        
        let date = Array(transactionsByDate.keys)[indexPath.section]
        if let transaction = transactionsByDate[date]?[indexPath.row] {
            cell.configure(with: transaction)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(transactionsByDate.keys)[section]
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            fetchTransactions()
        }
    }
    
    // MARK: - Work with Core Data
    func fetchBalance() {
        let request = Balance.fetchRequest()
        do {
            self.balance = try context.fetch(request)
            
            if self.balance?.isEmpty ?? true {
                let initialBalance = Balance(context: context)
                initialBalance.bitcoins = 0.0
                try context.save()
                self.balance = [initialBalance]
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.bitcoinsBalance.text = "\(String(describing: self.balance!.first!.bitcoins)) ₿"
            self.transactionsTableView.reloadData()
        }
    }
    
    func fetchTransactions() {
        let request = Transaction.fetchRequest()
        
        request.fetchLimit = transactionsPerPage
        request.fetchOffset = loadedTransactionsCount
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let fetchedTransactions = try context.fetch(request)
            transactions += fetchedTransactions
            
            transactionsByDate = Dictionary(grouping: transactions) { transaction in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                return dateFormatter.string(from: transaction.date!)
            }
            
            loadedTransactionsCount += fetchedTransactions.count
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.transactionsTableView.reloadData()
        }
    }
    
    
    func fetchRateFromCD() {
        let request = Rate.fetchRequest()
        
        do {
            let fetchedRate = try context.fetch(request)
            try context.save()
            let doubleRate = fetchedRate.first?.dollars
            rate = String(describing: doubleRate)
        } catch {
            print("Error fetching rate: \(error.localizedDescription)")
        }
    }
    
    func fetchTime() {
        do {
            let time = try context.fetch(Time.fetchRequest())
            if (!time.isEmpty) {
                timeOfLastUpdate = time.first?.lastUpdate
            }
        } catch {
            print("Error fetching balance: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.bitcoinsBalance.text = "\(String(describing: self.balance!.first!.bitcoins)) ₿"
            self.transactionsTableView.reloadData()
        }
    }
    
}

extension FirstViewController: SecondViewControllerDelegate {
    
    var context: NSManagedObjectContext { (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    
    func addTransaction() {
        fetchTransactions()
        fetchBalance()
        
        transactionsTableView.reloadData()
    }
}
