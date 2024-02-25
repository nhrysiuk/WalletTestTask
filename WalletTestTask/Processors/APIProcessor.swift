//
//  APIProcessor.swift
//  WalletTestTask
//
//  Created by Анастасія Грисюк on 25.02.2024.
//

import Foundation

struct APIProcessor {
    static func fetchExchangeRate() async -> String? {
        
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Server responded with an error")
                return nil
            }
            
            let decoder = JSONDecoder()
            let fullRate = try decoder.decode(FullRate.self, from: data)
            
            let rate = fullRate.bpi.usd.rate
            
            return rate
        } catch {
            print("Error fetching data: \(error)")
            return nil
        }
    }
}

// MARK: - Rate model
struct FullRate: Codable {
    let bpi: Bpi
}

struct Bpi: Codable {
    let usd: Usd

    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

struct Usd: Codable {
    let rate: String
}
