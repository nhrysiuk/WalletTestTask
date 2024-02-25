//
//  CoreDataProcessor.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 25.02.2024.
//

import Foundation
import CoreData
import UIKit

class CoreDataProcessor {

    static let shared = CoreDataProcessor.init()
    
    var context: NSManagedObjectContext { (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    
    func fetch<T: NSManagedObject>(_ type: T.Type) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        if T.self == Transaction.self {
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
        }

        let data = (try? context.fetch(request)) ?? []
        
        return data
    }
    
    func saveContext() {
        try? context.save()
    }
}
