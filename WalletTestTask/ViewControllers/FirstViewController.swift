//
//  FirstViewController.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 24.02.2024.
//


import UIKit
import CoreData

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
    
    var transactionsPerPage = 20
    var loadedTransactionsCount = 0
    var sections = [Section]()
    
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
        
        let rightBarButtonItem = UIBarButtonItem(customView: createLabelView())
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        setupStackView()
        setupAddTransaction()
        setupTransactionsTableView()
    }
    
    func createLabelView() -> UIView {
        rateLabel.textColor = .lightGray
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
        let time = CoreDataProcessor.shared.fetch(Time.self)
        
        if (!time.isEmpty) {
            timeOfLastUpdate = time.first?.lastUpdate
        }
        
        if timeOfLastUpdate == nil || Date().timeIntervalSince(timeOfLastUpdate!) >= 3600 {
            Task {
                await fetchRateFromAPI()
                self.rateLabel.text = "$ \(self.rate ?? "0")"
            }
        } else {
            let fetchedRate = CoreDataProcessor.shared.fetch(BitcoinRate.self)
            let doubleRate = fetchedRate.last?.dollars
            rate = doubleRate!
            self.rateLabel.text = "$ \(self.rate!)"
        }
    }
    
    func setupStackView() {
        bitcoinsBalance.textColor = .white
        bitcoinsBalance.text = "0 ₿"
        bitcoinsBalance.font = .systemFont(ofSize: 50, weight: .semibold)
        bitcoinsBalance.numberOfLines = 0
        fillUpBalance.addTarget(self, action: #selector(fillUpButtonTapped), for: .touchUpInside)
        view.addSubview(stackView)
        bitcoinsBalance.layer.shadowColor = UIColor.white.cgColor
        bitcoinsBalance.layer.shadowOffset = CGSize(width: 0, height: 0)
        bitcoinsBalance.layer.shadowOpacity = 0.8
        bitcoinsBalance.layer.shadowRadius = 6
        
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
        addTransactionButton.setTitleColor(.turquoise, for: .normal)
        addTransactionButton.backgroundColor = .darkGray
        addTransactionButton.layer.cornerRadius = 7
        
        
        addTransactionButton.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        view.addSubview(addTransactionButton)
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTransactionButton.topAnchor.constraint(equalTo: bitcoinsBalance.bottomAnchor,
                                                      constant: 5),
            addTransactionButton.widthAnchor.constraint(equalToConstant: 170),
        ])
    }
    
    func setupTransactionsTableView() {
        transactionsTableView.backgroundColor = .black
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
               let enteredNumber = textField.text,  let number = Double(enteredNumber), number > 0 {
                do {
                    let fetchRequest: NSFetchRequest<Balance> = Balance.fetchRequest()
                    if let existingBalance = try CoreDataProcessor.shared.context.fetch(fetchRequest).first {
                        existingBalance.bitcoins += number
                    } else {
                        let newBalance = Balance(context: CoreDataProcessor.shared.context)
                        newBalance.bitcoins = number
                    }
                    
                    let transaction = Transaction(context: CoreDataProcessor.shared.context)
                    transaction.bitcoins = number
                    transaction.category = "fill up"
                    transaction.date = Date()
                    
                    do {
                        try CoreDataProcessor.shared.context.save()
                    } catch {
                        print("Couldn't save transaction: \(error.localizedDescription)")
                    }
                    
                    addTransaction()
                    self.fetchBalance()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                let wrongAlertController = UIAlertController(title: "You've entered something wrong",
                                                             message: "Please enter a valid number next time",
                                                             preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                wrongAlertController.addAction(cancelAction)
                present(wrongAlertController, animated: true, completion: nil)
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as? TransactionTableViewCell else {
            fatalError("oops")
        }
        
        let transaction = sections[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.dateFormat
        
        let date = sections[section].date
        return date
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
    
    // MARK: - Work with Core Data and API
    func fetchBalance() {
        self.balance = CoreDataProcessor.shared.fetch(Balance.self)
        
        if self.balance?.isEmpty ?? true {
            let initialBalance = Balance(context: CoreDataProcessor.shared.context)
            initialBalance.bitcoins = 0.0
            CoreDataProcessor.shared.saveContext()
            self.balance = [initialBalance]
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
        var fetchedTransactions = [Transaction]()
        do {
            fetchedTransactions = try CoreDataProcessor.shared.context.fetch(request)
            
            if !fetchedTransactions.isEmpty {
                transactions += fetchedTransactions
                
                transactionsByDate = Dictionary(grouping: transactions) { transaction in
                    return formatDate(transaction.date!)
                }
            
                for (date, transactionsOnDay) in transactionsByDate.sorted(by: { $0.key < $1.key }) {
                    if let existingSectionIndex = sections.firstIndex(where: { $0.date == date }) {
                        self.sections[existingSectionIndex].transactions += transactionsOnDay
                    } else {
                        let newSection = Section(date: date, transactions: transactionsOnDay)
                        self.sections.insert(newSection, at: 0)
                    }
                }
            }
            sections.sort { (section1, section2) -> Bool in
                return section1.date > section2.date
            }
            loadedTransactionsCount += fetchedTransactions.count
        } catch {
            print("Error fetching transactions: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            if !fetchedTransactions.isEmpty {
                self.transactionsTableView.reloadData()
            }
        }
    }
    
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.dateFormat
        return dateFormatter.string(from: date)
    }
    
    func fetchRateFromAPI() async {
        rate = await APIProcessor.fetchExchangeRate() ?? "no data"
        let existingRateEntities = CoreDataProcessor.shared.fetch(BitcoinRate.self)
        if let existingRate = existingRateEntities.first {
            existingRate.dollars = self.rate!
        } else {
            let newRate = BitcoinRate(context: CoreDataProcessor.shared.context)
            newRate.dollars = self.rate!
            CoreDataProcessor.shared.saveContext()
        }
        
        CoreDataProcessor.shared.saveContext()
        
        timeOfLastUpdate = Date()
        
        let existingTimeEntities = CoreDataProcessor.shared.fetch(Time.self)
        
        if let existingTime = existingTimeEntities.first {
            existingTime.lastUpdate = timeOfLastUpdate
        } else {
            let newTime = Time(context: CoreDataProcessor.shared.context)
            newTime.lastUpdate = timeOfLastUpdate
        }
        
        let time = Time(context: CoreDataProcessor.shared.context)
        time.lastUpdate = timeOfLastUpdate
    }
}

extension FirstViewController: SecondViewControllerDelegate {
    
    func addTransaction() {
        loadedTransactionsCount = 0
        transactions = []
        transactionsByDate = [:]
        sections = []
        
        fetchTransactions()
        fetchBalance()
        
        transactionsTableView.reloadData()
    }
}
